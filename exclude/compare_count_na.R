#' # R Benchmarking: What is the fastest way to count NAs?

library(bench)
library(dplyr)

# 6 million random numbers + 1 million NAs
set.seed(12345)
numbers <- c(
    rcauchy(n = 1e6),
    rexp(n = 1e6),
    rlogis(n = 1e6),
    rlnorm(n = 1e6),
    rnorm(n = 1e6),
    runif(n = 1e6),
    rep(NA_real_, 1e6)
) %>% sample()


mark(
    summary = summary(numbers)[7],
    sum_is.na = sum(is.na(numbers)),
    sum_is.na_length = sum(is.na(numbers)) / length(numbers),
    mean_is.na = mean(is.na(numbers)),
    length_complete = sum(!complete.cases(numbers)),
    in_na = numbers %in% NA_real_,
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(desc(n_itr))
