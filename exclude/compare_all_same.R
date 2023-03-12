#' # R Benchmarking: Are all elements in a vector the same?

library(bench)
library(dplyr)
options(width = 110)

set.seed(12345)
identical_str <- c(rep("A test string", 6e6), NA_character_)
identical_dbl <- c(rep(7.3443123, 6e6), NA_real_)

mixed_str <- c(rep(month.name, 6e6), NA_character_)
mixed_dbl <- c(rnorm(6e6), NA_real_)

# ---- Functions -----------------------------

length_unique <- function(x, na.rm = FALSE) {
    # https://stackoverflow.com/a/31969295/5578429
    if (na.rm) { x <- x[!is.na(x)] }
    length(unique(x)) == 1
}

head_vs_body <- function(x, na.rm = FALSE) {
    # https://stackoverflow.com/a/31968881/5578429
    if (na.rm) { x <- x[!is.na(x)] }
    all(x[1] == x[-1])
}

head_vs_body2 <- function(x, na.rm = FALSE) {
    # https://stackoverflow.com/a/59067398/5578429
    if (na.rm) { x <- x[!is.na(x)] }
    all(x[1] == x)
}

sum_not_dupe <- function(x, na.rm = FALSE) {
    # https://stackoverflow.com/a/31968831/5578429
    if (na.rm) { x <- x[!is.na(x)] }
    sum(!duplicated(x)) == 1
}



mark(
    str_ident_length_unique = length_unique(identical_str, na.rm = TRUE),
    str_ident_head_vs_body = head_vs_body(identical_str, na.rm = TRUE),
    str_ident_head_vs_body2 = head_vs_body2(identical_str, na.rm = TRUE),
    str_ident_sum_not_dupe = sum_not_dupe(identical_str, na.rm = TRUE),
    dbl_ident_length_unique = length_unique(identical_dbl, na.rm = TRUE),
    dbl_ident_head_vs_body = head_vs_body(identical_dbl, na.rm = TRUE),
    dbl_ident_head_vs_body2 = head_vs_body2(identical_dbl, na.rm = TRUE),
    dbl_ident_sum_not_dupe = sum_not_dupe(identical_dbl, na.rm = TRUE),
    str_mixed_length_unique = length_unique(mixed_str),
    str_mixed_head_vs_body = head_vs_body(mixed_str),
    str_mixed_head_vs_body2 = head_vs_body2(mixed_str),
    str_mixed_sum_not_dupe = sum_not_dupe(mixed_str),
    dbl_mixed_length_unique = length_unique(mixed_dbl),
    dbl_mixed_head_vs_body = head_vs_body(mixed_dbl),
    dbl_mixed_head_vs_body2 = head_vs_body2(mixed_dbl),
    dbl_mixed_sum_not_dupe = sum_not_dupe(mixed_dbl),
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(desc(`itr/sec`))
