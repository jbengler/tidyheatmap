
bro_string_diff <- function(x) {
  (x[-length(x)] != x[-1]) %>%
    which(.)
}

wrangle_data <- function(df, rows, columns, values, ann_row = NULL, ann_col = NULL, gaps_row = NULL, gaps_col = NULL){
  m <-
    df %>%
    select({{rows}}, {{columns}}, {{values}}) %>%
    pivot_wider(names_from = {{columns}}, values_from = {{values}}) %>%
    column_to_rownames(colnames(.)[1])

  if(!rlang::quo_is_null(enquo(ann_col))) {
    ann_col <-
      df %>%
      select({{columns}}, {{ann_col}}) %>%
      distinct() %>%
      column_to_rownames(colnames(.)[1])
  } else ann_col <- NA

  if(!rlang::quo_is_null(enquo(ann_row))) {
    ann_row <-
      df %>%
      select({{rows}}, {{ann_row}}) %>%
      distinct() %>%
      column_to_rownames(colnames(.)[1])
  } else ann_row <- NA

  if(!rlang::quo_is_null(enquo(gaps_row))) {
    gaps_row <-
      df %>%
      select({{rows}}, {{gaps_row}}) %>%
      distinct() %>%
      pull({{gaps_row}}) %>%
      bro_string_diff()
  }

  if(!rlang::quo_is_null(enquo(gaps_col))) {
    gaps_col <-
      df %>%
      select({{columns}}, {{gaps_col}}) %>%
      distinct() %>%
      pull({{gaps_col}}) %>%
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
#' @param ann_row,ann_col Column(s) of the dataframe to use for row and column annotation.
#' Multiple columns can be provided as vector, e.g. `c(column1, column2, column3)`.
#' @param gaps_row,gaps_col Column of the dataframe to use for row and column gaps.
#' @param ann_colors List of colors used to color code row and column annotations.
#' See `pheatmap::pheatmap()` for details.
#' @param color_scale_min,color_scale_max Minimal and maximal value on color scale.
#' @param color_scale_n Number of color on color scale.
#' @param breaks Sequence used for mapping values to colors. Is one element longer than `color_scale_n`.
#' See `pheatmap::pheatmap()` for details.
#' @param scale Character indicating if the values should be centered and scaled by "row", "column" or "none".
#' Default is "row".
#' @param fontsize Base fontsize for the plot.
#' @param cellwidth,cellheight Cell width and hieght in points. If left `NA`, cells will scale to fill the available space.
#' @param color Vector of colors used in heatmap.
#' @param return_data If `TRUE` processed data is returned instead of plot.
#' @param ... Other parameters passed to `pheatmap::pheatmap()`.
#'
#' @export
tidy_heatmap <- function(df, rows, columns, values, filename = NA, ann_row = NULL, ann_col = NULL,
                         gaps_row = NULL, gaps_col = NULL, ann_colors = NA, breaks = NA,
                         scale = "none", fontsize = 7, cellwidth = NA, cellheight = NA,
                         color_scale_min = NA, color_scale_max = NA, color_scale_n = 100,
                         color = colorRampPalette(rev(RColorBrewer::brewer.pal(n = 7, name ="RdYlBu")))(color_scale_n),
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
