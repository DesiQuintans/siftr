#' # R Benchmarking: Removing NA values

library(bench)
library(dplyr)

set.seed(12345)

# 6 million Characters and Doubles with NAs.
na_chr <- sample(c(state.name, NA), size = 6e6, replace = TRUE)
na_dbl <- sample(c(rnorm(50) , NA), size = 6e6, replace = TRUE)

# About 117k NAs in each vector.
sum(is.na(na_chr))
sum(is.na(na_dbl))

mark(
    chr_na.omit    = na.omit(na_chr),
    dbl_na.omit    = na.omit(na_dbl),
    chr_na.exclude = na.exclude(na_chr),
    dbl_na.exclude = na.exclude(na_dbl),
    chr_is.na      = na_chr[!is.na(na_chr)],
    dbl_is.na      = na_dbl[!is.na(na_dbl)],
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(desc(`itr/sec`))
