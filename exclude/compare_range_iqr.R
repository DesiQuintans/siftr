#' # What is the fastest way to find range and IQR?

library(dplyr)
library(bench)
set.seed(12345)

# 6 million random numbers + 1 million NAs
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
    range = range(numbers, na.rm = TRUE),
    min_max = c(min(numbers, na.rm = TRUE), max(numbers, na.rm = TRUE)),
    summary_range = summary(numbers)[c(1, 6)],
    summary_iqr = summary(numbers)[c(2, 5)],
    fivenum_range = fivenum(numbers, na.rm = TRUE)[c(1, 5)],
    fivenum_iqr = fivenum(numbers, na.rm = TRUE)[c(2, 4)],
    quantile = quantile(numbers, c(0.25, 0.75), na.rm = TRUE),
    sort_head_tail = c(head(sort(numbers), 1), tail(sort(numbers), 1)),
    check = FALSE,
    relative = TRUE,
    filter_gc = FALSE
) %>% arrange(min) %>% {.[, 1:9]}
