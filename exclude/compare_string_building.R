#' What is the fastest way to build a string with variables inserted in it?

library(dplyr)
library(stringr)
library(glue)
library(R.utils)
library(bench)

set.seed(12345)
test1 <- sample(c(month.abb, state.name, state.region), size = 1e6, replace = TRUE)
test2 <- sample(c(month.abb, state.name, state.region), size = 1e6, replace = TRUE)

mark(
    paste = paste("Assemble", test1, "and", test2, "."),
    paste0 = paste0("Assemble ", test1, " and ", test2, "."),
    sprintf = sprintf("Assemble %1$s and %2$s", test1, test2),
    str_glue = str_glue("Assemble {test1} and {test2}."),
    glue = glue("Assemble {test1} and {test2}."),
    GString = GString("Assemble ${test1} and ${test2}."),  # Returns a GString obj
    gstring = gstring("Assemble ${test1} and ${test2}."),  # Coerces to Character
    check = FALSE,
    relative = TRUE,
    filter_gc = FALSE
) %>% arrange(desc(n_itr)) %>% select(1:9)

