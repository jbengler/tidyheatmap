
globalVariables(".")
#' @importFrom dplyr %>%


bro_string_diff <- function(x) {
  (x[-length(x)] != x[-1]) %>%
    which(.)
}

wrangle_data <- function(df, rows, columns, values, annotation_row = NULL, annotation_col = NULL, gaps_row = NULL, gaps_col = NULL){
  m <-
    df %>%
    dplyr::select({{rows}}, {{columns}}, {{values}}) %>%
    tidyr::pivot_wider(names_from = {{columns}}, values_from = {{values}}) %>%
    tibble::column_to_rownames(colnames(.)[1])

  if(!rlang::quo_is_null(rlang::enquo(annotation_col))) {
    annotation_col <-
      df %>%
      dplyr::select({{columns}}, {{annotation_col}}) %>%
      dplyr::distinct() %>%
      tibble::column_to_rownames(colnames(.)[1])
  } else annotation_col <- NA

  if(!rlang::quo_is_null(rlang::enquo(annotation_row))) {
    annotation_row <-
      df %>%
      dplyr::select({{rows}}, {{annotation_row}}) %>%
      dplyr::distinct() %>%
      tibble::column_to_rownames(colnames(.)[1])
  } else annotation_row <- NA

  if(!rlang::quo_is_null(rlang::enquo(gaps_row))) {
    gaps_row <-
      df %>%
      dplyr::select({{rows}}, {{gaps_row}}) %>%
      dplyr::distinct() %>%
      dplyr::pull({{gaps_row}}) %>%
      bro_string_diff()
  }

  if(!rlang::quo_is_null(rlang::enquo(gaps_col))) {
    gaps_col <-
      df %>%
      dplyr::select({{columns}}, {{gaps_col}}) %>%
      dplyr::distinct() %>%
      dplyr::pull({{gaps_col}}) %>%
      bro_string_diff()
  }

  list(m = m, annotation_row = annotation_row, annotation_col = annotation_col, gaps_row = gaps_row, gaps_col = gaps_col)
}

#' Plot pretty heatmaps from tidy data
#'
#' This function is a wrapper around `pheatmap::pheatmap()` that allows long tidy
#' data as input.
#'
#' @param df Input dataframe in long format.
#'
#' @param rows Column of the dataframe to use for heatmap rows.
#' @param columns Column of the dataframe to use for heatmap columns.
#' @param values Column of the dataframe containing the values to plot.
#'
#' @param colors Vector of colors used to encode values in heatmap.
#' @param color_scale_n Number of colors in color scale.
#' @param color_scale_min todo
#' @param color_scale_max todo
#' @param color_na todo
#'
#' @param annotation_row todo
#' @param annotation_col todo
#' @param gaps_row todo
#' @param gaps_col todo
#' @inheritParams pheatmap::pheatmap
#'
#' @export
tidy_heatmap <- function(df,
                         rows,
                         columns,
                         values,

                         colors = NA,
                         color_scale_n = 15,
                         color_scale_min = NA,
                         color_scale_max = NA,
                         color_na = "#DDDDDD",

                         annotation_row = NULL,
                         annotation_col = NULL,
                         gaps_row = NULL,
                         gaps_col = NULL,

                         filename = NA,
                         scale = "none",
                         fontsize = 7,
                         cellwidth = NA,
                         cellheight = NA,
                         cluster_rows = FALSE,
                         cluster_cols = FALSE,
                         border_color = NA,

                         kmeans_k = NA,
                         clustering_distance_rows = "euclidean",
                         clustering_distance_cols = "euclidean",
                         clustering_method = "complete",
                         clustering_callback = function(x, ...){return(x)},
                         cutree_rows = NA,
                         cutree_cols = NA,
                         treeheight_row = ifelse((class(cluster_rows) == "hclust") || cluster_rows, 50, 0),
                         treeheight_col = ifelse((class(cluster_cols) == "hclust") || cluster_cols, 50, 0),
                         legend = TRUE,
                         legend_breaks = NA,
                         legend_labels = NA,
                         annotation_colors = NA,
                         annotation_legend = TRUE,
                         annotation_names_row = TRUE,
                         annotation_names_col = TRUE,
                         drop_levels = TRUE,
                         show_rownames = TRUE,
                         show_colnames = TRUE,
                         main = NA,
                         fontsize_row = fontsize,
                         fontsize_col = fontsize,
                         angle_col = c("270", "0", "45", "90", "315"),
                         display_numbers = FALSE,
                         number_format = "%.2f",
                         number_color = "grey30",
                         fontsize_number = 0.8 * fontsize,
                         width = NA,
                         height = NA,
                         silent = FALSE) {

  heatmap_data <-
    wrangle_data(df, {{rows}}, {{columns}}, {{values}}, annotation_row = {{annotation_row}}, annotation_col = {{annotation_col}}, gaps_row = {{gaps_row}}, gaps_col = {{gaps_col}})

  breaks <- NA
  if(is.numeric(color_scale_min) & is.numeric(color_scale_max) & is.numeric(color_scale_n))
    breaks <- seq(color_scale_min, color_scale_max, length.out = color_scale_n)

  if (is.na(colors))
    colors <-  rev(RColorBrewer::brewer.pal(n = 7, name ="RdYlBu"))

  pheatmap::pheatmap(heatmap_data$m,
                     color = grDevices::colorRampPalette(colors)(color_scale_n),
                     breaks = breaks,
                     na_col = color_na,

                     annotation_row = heatmap_data$annotation_row,
                     annotation_col = heatmap_data$annotation_col,
                     gaps_row = heatmap_data$gaps_row,
                     gaps_col = heatmap_data$gaps_col,

                     filename = filename,
                     scale = scale,
                     fontsize = fontsize,
                     cellwidth = cellwidth,
                     cellheight = cellheight,
                     cluster_rows = cluster_rows,
                     cluster_cols = cluster_cols,
                     border_color = border_color,

                     kmeans_k = kmeans_k,
                     clustering_distance_rows = clustering_distance_rows,
                     clustering_distance_cols = clustering_distance_cols,
                     clustering_method = clustering_method,
                     clustering_callback = clustering_callback,
                     cutree_rows = cutree_rows,
                     cutree_cols = cutree_cols,
                     treeheight_row = treeheight_row,
                     treeheight_col = treeheight_col,
                     legend = legend,
                     legend_breaks = legend_breaks,
                     legend_labels = legend_labels,
                     annotation_colors = annotation_colors,
                     annotation_legend = annotation_legend,
                     annotation_names_row = annotation_names_row,
                     annotation_names_col = annotation_names_col,
                     drop_levels = drop_levels,
                     show_rownames = show_rownames,
                     show_colnames = show_colnames,
                     main = main,
                     fontsize_row = fontsize_row,
                     fontsize_col = fontsize_col,
                     angle_col = angle_col,
                     display_numbers = display_numbers,
                     number_format = number_format,
                     number_color = number_color,
                     fontsize_number = fontsize_number,
                     width = width,
                     height = height,
                     silent = silent)
}
