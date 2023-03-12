#' # What is the fastest way to round/truncate numbers?

library(dplyr)
library(bench)
set.seed(12345)

# 6 million random numbers
numbers <- c(
    rcauchy(n = 1e6),
    rexp(n = 1e6),
    rlogis(n = 1e6),
    rlnorm(n = 1e6),
    rnorm(n = 1e6),
    runif(n = 1e6)
)


mark(
    round   = round(numbers, digits = 0),
    sprintf = sprintf("%.0f", numbers),
    ceiling = ceiling(numbers),
    floor   = floor(numbers),
    trunc   = trunc(numbers),
    check = FALSE,
    relative = TRUE,
    filter_gc = FALSE
) %>% arrange(min) %>% select(1:8)
