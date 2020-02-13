
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyheatmap

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/jbengler/tidyheatmap.svg?branch=master)](https://travis-ci.org/jbengler/tidyheatmap)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Codecov test
coverage](https://codecov.io/gh/jbengler/tidyheatmap/branch/master/graph/badge.svg)](https://codecov.io/gh/jbengler/tidyheatmap?branch=master)
<!-- badges: end -->

The goal of `tidyheatmap` is to provide a tidyverse-style interface to
the powerful heatmap package
[pheatmap](https://github.com/raivokolde/pheatmap) by
[@raivokolde](https://github.com/raivokolde). This enables the
convenient generation of complex heatmaps from tidy data.

## Installation

You can install `tidyheatmap` from GitHub with:

``` r
# install.packages("devtools")

devtools::install_github("jbengler/tidyheatmap")
```

## Example

Given a tidy data frame of gene expression data like `data_exprs`, you
can easily generate a basic heatmap.

``` r
library(tidyheatmap)

data_exprs
#> # A tibble: 800 x 12
#>    ensembl_gene_id external_gene_n… Eip_vs_Hip.padj direction is_immune_gene
#>    <chr>           <chr>                      <dbl> <chr>     <chr>         
#>  1 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  2 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  3 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  4 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  5 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  6 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  7 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  8 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#>  9 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#> 10 ENSMUSG0000003… Apol6                   3.79e-28 up        no            
#> # … with 790 more rows, and 7 more variables: count_type <chr>, group <chr>,
#> #   replicate <chr>, expression <dbl>, sample <chr>, sample_type <chr>,
#> #   condition <chr>
#> # A tibble: 800 x 3
#>    external_gene_name sample expression
#>    <chr>              <chr>       <dbl>
#>  1 Bsn                Hin_1        9.59
#>  2 Bsn                Hin_2        9.48
#>  3 Bsn                Hin_3        9.66
# ...

tidy_heatmap(data_exprs,
             rows = external_gene_name,
             columns = sample,
             values = expression,
             ann_col = c(sample_type, condition, group),
             scale = "row",
             color_scale_n = 16,
             color_scale_min = -2,
             color_scale_max = 2,
             gaps_row = direction,
             gaps_col = group
)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

## Documentation

<https://jbengler.github.io/tidyheatmap/>
