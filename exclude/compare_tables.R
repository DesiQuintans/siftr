
#' What is the fastest way to make a summary table?

library(bench)
library(dplyr)

set.seed(12345)
states <- sample(state.name, size = 6e6, replace = TRUE, prob = abs(rnorm(50)))

mark(
    table = table(states),
    aggregate = aggregate(x = list(states), by = list(states), FUN = length),
    check = FALSE,
    relative = TRUE,
    filter_gc = FALSE
) %>% arrange(desc(n_itr)) %>% select(1:9)

