
globalVariables(".")
#' @importFrom dplyr %>%
bro_string_diff <- function(x) {
  (x[-length(x)] != x[-1]) %>%
    which(.)
}

wrangle_data <- function(df, rows, columns, values, ann_row = NULL, ann_col = NULL, gaps_row = NULL, gaps_col = NULL){
  m <-
    df %>%
    dplyr::select({{rows}}, {{columns}}, {{values}}) %>%
    tidyr::pivot_wider(names_from = {{columns}}, values_from = {{values}}) %>%
    tibble::column_to_rownames(colnames(.)[1])

  if(!rlang::quo_is_null(rlang::enquo(ann_col))) {
    ann_col <-
      df %>%
      dplyr::select({{columns}}, {{ann_col}}) %>%
      dplyr::distinct() %>%
      tibble::column_to_rownames(colnames(.)[1])
  } else ann_col <- NA

  if(!rlang::quo_is_null(rlang::enquo(ann_row))) {
    ann_row <-
      df %>%
      dplyr::select({{rows}}, {{ann_row}}) %>%
      dplyr::distinct() %>%
      tibble::column_to_rownames(colnames(.)[1])
  } else ann_row <- NA

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

  list(m = m, ann_row = ann_row, ann_col = ann_col, gaps_row = gaps_row, gaps_col = gaps_col)
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
#' @param ann_colors List of colors used to color code row and column annotations.
#' See `pheatmap::pheatmap()` for details.
#' @param color_scale_n Number of color on color scale.
#' @param breaks Sequence used for mapping values to colors. Is one element longer than `color_scale_n`.
#' See `pheatmap::pheatmap()` for details.
#' @param scale Character indicating if the values should be centered and scaled by "row", "column" or "none".
#' Default is "row".
#' @param fontsize Base fontsize for the plot.
#' @param color Vector of colors used in heatmap.
#' @param return_data If `TRUE` processed data is returned instead of plot.
#' @param ... Other parameters passed to `pheatmap::pheatmap()`.
#' @param filename todo
#' @param ann_row todo
#' @param ann_col todo
#' @param gaps_row todo
#' @param gaps_col todo
#' @param cellwidth todo
#' @param cellheight todo
#' @param color_scale_min todo
#' @param color_scale_max todo
#' @param cluster_rows todo
#' @param cluster_cols todo
#' @param border_color todo
#'
#' @export
tidy_heatmap <- function(df, rows, columns, values, filename = NA, ann_row = NULL, ann_col = NULL,
                         gaps_row = NULL, gaps_col = NULL, ann_colors = NA, breaks = NA,
                         scale = "none", fontsize = 7, cellwidth = NA, cellheight = NA,
                         color_scale_min = NA, color_scale_max = NA, color_scale_n = 100,
                         color = grDevices::colorRampPalette(rev(RColorBrewer::brewer.pal(n = 7, name ="RdYlBu")))(color_scale_n),
                         return_data = FALSE, cluster_rows = FALSE, cluster_cols = FALSE, border_color = NA, ...) {

  heatmap_data <-
    wrangle_data(df, {{rows}}, {{columns}}, {{values}}, ann_row = {{ann_row}}, ann_col = {{ann_col}}, gaps_row = {{gaps_row}}, gaps_col = {{gaps_col}})

  if(is.numeric(color_scale_min) & is.numeric(color_scale_max) & is.numeric(color_scale_n)) {
    breaks <- seq(color_scale_min, color_scale_max, length.out = color_scale_n)
  }

  if (return_data) {
    heatmap_data
  } else {
    pheatmap::pheatmap(heatmap_data$m,
                       cluster_rows = cluster_rows,
                       cluster_cols = cluster_cols,
                       border_color = border_color,
                       annotation_row = heatmap_data$ann_row,
                       annotation_col = heatmap_data$ann_col,
                       gaps_row = heatmap_data$gaps_row,
                       gaps_col = heatmap_data$gaps_col,
                       annotation_colors = ann_colors,
                       scale = scale,
                       fontsize = fontsize,
                       cellwidth = cellwidth,
                       cellheight = cellheight,
                       color = color,
                       breaks = breaks,
                       filename = filename,
                       ...)
  }
}
