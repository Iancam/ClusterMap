####################### Recolor #######################

#' recolor_s
#'
#' Recolor a single sample based on the matching results from cluster_map_by_marker.
#'
#' @import Seurat
#'
#' @param mapRes_sub
#' A vector of the column named by the sample in the output of cluster_map_by_marker, with the regroup column as the vector name.
#' @param obj
#' A Seurat object for the sample.
#' @param output
#' The output directory to save the plot.
#' @param color
#' A vector of colors used to recolor the new groups. DEFAULT is NULL. Pre defined internal color will be used.
#' @return A vector of new group labels with the cell name as the vector name.
#' @export


recolor_s <- function(mapRes_sub, obj, output, single_obj_list, color = NULL)
{
	## recolor_s will call function gg_colr_hue.
	message(paste0("recolor ", output))
	if (is.null(names(mapRes_sub))) stop("There is no name of mapRes_sub.")
	l <- lapply(strsplit(mapRes_sub, ';'), sub, pattern = '.*_', replacement = '')
	new_match <- setNames(unlist(l, use.names = F), rep(names(l), lengths(l)))
	if(single_obj_list[[1]]@version > 3){
		print("Using Seurat v3")
		new_group <- Idents(object = obj)
		levels(new_group) <- names(new_match)[match(levels(Idents(object=obj)), new_match)]
	} else {
        new_group <- obj@idents
        levels(new_group) <- names(new_match)[match(levels(obj@idents), new_match)]
	}
    new_group <- factor(new_group, levels = names(mapRes_sub))
	## t-SNE plot
    obj$regroup <- new_group
	
	if(single_obj_list[[1]]@version < 3){	
		if (is.null(color)) color <- gg_color_hue(length(levels(new_group)))
			png(paste0(output, '.recolor.tsne.png'))
				TSNEPlot(obj, do.label = T, label.size = 8, group.by = 'regroup',
					colors.use = color[sort(as.numeric(unique(new_group)))], plot.title = toupper(output))
			dev.off()
			pdf(paste0(output, '.recolor.tsne.pdf'))
				TSNEPlot(obj, do.label = T, label.size = 8, group.by = 'regroup',
					colors.use = color[sort(as.numeric(unique(new_group)))], plot.title = toupper(output))
			dev.off()
			return(new_group)
	}

  else{	
	  print("Using Seurat v3")
	  if (is.null(color)) color <- gg_color_hue(length(levels(new_group)))
		lapply(knownReductions(obj), function(reduction){
			savePlot(
				DimPlot(
					obj,
					label = T,
					label.size = 8,
					group.by = 'regroup',
					reduction = reduction,
					cols = color[sort(as.numeric(unique(new_group)))])
				+ ggtitle(paste(toupper(output))),
				paste0(output, '.recolor.', reduction)
			)
		})
		
		return(new_group)
	}	   
}
#' recolor_comb
#'
#' Recolor the combined sample based on the matching results from recolor_s.
#'
#' @import Seurat
#'
#' @param comb_obj
#' A Seurat object for the combined sample. Cells in different samples are labelled by the sample names with the comb_delim.
#' @param new_group_list
#' A list of vectors of new group assignment outputted from recolor_s.
#' @param output
#' The output directory to save the plot.
#' @param comb_delim
#' The delimiter used in the cell names in the combined object to connect sample name and cell name in individual sample. DEFAULT is '-'.
#' @param color
#' A vector of colors used to recolor the new groups. DEFAULT is NULL. Pre defined internal color will be used.
#' @return A vector of new group labels with the cell name as the vector name.
#' @export


recolor_comb <- function(comb_obj, new_group_list, output, single_obj_list, comb_delim = NULL, color = NULL)
{
	# Change comb_delim if v3 Seurat
	if(is.null(comb_delim)) {
		if(comb_obj@version > 3){
			comb_delim = '_'
			print("Changed comb_delim to '_'")
		} else {
			comb_delim = '-'
		}
	}
	

	## recolor_comb will call function gg_color_hue.
	message(paste0("recolor ", output))

  sample_label <- as.factor(sub(paste0(comb_delim, '.*'), '', colnames(GetAssayData(object = comb_obj))))
	message("levels(sample_label):")
	print(levels(sample_label))
	message("names(new_group_list):")
	print(names(new_group_list))
  if (all(levels(sample_label) == names(new_group_list)) == FALSE)
		stop("Sample label in comb_obj doesn't match names(new_group_list) or names(single_obj_list).")
	names(sample_label) <- colnames(GetAssayData(object = comb_obj))
	## color by samples
	comb_obj$samples <- sample_label

	if (comb_obj@version <3) {
		print("Seurat v2")
		savePlot(TSNEPlot(comb_obj, do.label = F, label.size = 8, group.by = 'samples', plot.title = 'Colored by sample'),
		paste0(output, '.color.by.sample.tsne')
		)
		## assign new group
		new_group <- assignGroup(new_group_list, comb_delim, comb_obj)
		## color by new group
		comb_obj <- AddMetaData(object = comb_obj, metadata = new_group, col.name = "regroup")
		
		if (is.null(color)) color  <-  gg_color_hue(length(levels(new_group)))
		savePlot(TSNEPlot(comb_obj, do.label = T, label.size = 8, group.by = 'regroup',
				colors.use = color[sort(as.numeric(unique(new_group)))], plot.title = 'Combined'),
				paste0(output, '.recolor.tsne'))
		return(new_group)
	}
	else if(comb_obj@version >= 3) {
		print("Seurat v3 comb_obj")
		
		lapply(knownReductions(comb_obj), function(reduction){
			savePlot(DimPlot(comb_obj, label = F, label.size = 8, group.by = 'samples', 
				reduction = reduction) + ggtitle('Colored by sample'),
				paste0(output, '.color.by.sample.', reduction)
				)
		})
		## assign new group
		new_group <- assignGroup(new_group_list, comb_delim, comb_obj)
		## color by new group
		comb_obj <- AddMetaData(object = comb_obj, metadata = new_group, col.name = "regroup")
		if (is.null(color)) color  <-  gg_color_hue(length(levels(new_group)))
		
		lapply(knownReductions(comb_obj), function(reduction) {
			savePlot(
				DimPlot(
					comb_obj,
					label = T,
					label.size = 8, 
					reduction = reduction,
					group.by = 'regroup',
					cols = color[sort(as.numeric(unique(new_group)))]) 
				+ ggtitle('Combined'),
				paste0(output, '.recolor.', reduction)
			)
		})
		return(new_group)
	}
}

savePlot <- function(plot, name){
	png(paste0(name , '.png'))
		print(plot)
	dev.off()
	pdf(paste0(name , '.pdf'))
		print(plot)
	dev.off()
}

knownReductions <- function(obj) {intersect(c("tsne", "umap"), Reductions(obj))}

assignGroup <- function(new_group_list, comb_delim, comb_obj) {
	new_group <- unlist(new_group_list)
	names(new_group) <- sub('\\.', comb_delim, names(new_group))
		new_group <- factor(new_group, levels = levels(new_group_list[[1]]))
		new_group <- new_group[match(colnames(GetAssayData(object = comb_obj)), 
				as.vector(names(new_group)))] ## some cells may be filtered out in combined sample.
	if (is.na(new_group[1]))
		stop("Cell names in comb_obj don't match cell names in new_group_list or single_obj_list. Cell names in comb_obj should be sample name and cell name in individual sample connected by comb_delim.")
		names(new_group) <- colnames(GetAssayData(object = comb_obj))
	new_group
}