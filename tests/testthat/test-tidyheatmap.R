
test_that("data set 'data_exprs' is available", {
  expect_equal(dim(data_exprs), c(800, 9))
})

test_that("missing required arguments throws error", {
  expect_error(tidy_heatmap(), "'df' is missing")
  expect_error(tidy_heatmap(data_exprs), "'rows' is missing")
  expect_error(tidy_heatmap(data_exprs,
                            rows = external_gene_name), "'columns' is missing")
  expect_error(tidy_heatmap(data_exprs,
                            rows = external_gene_name,
                            columns = sample), "'values' is missing")
})

test_that("gtable output is produced", {
  expect_equal(tidy_heatmap(data_exprs,
                            rows = external_gene_name,
                            columns = sample,
                            values = expression)$gtable %>% class %>% .[1], "gtable")
})
