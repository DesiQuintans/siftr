# sapply() produces a list of vectors that each can have more than one element.
# Collapse each list element to a vector of length 1.
crunch <- function(x, sep = ", ") {
    vapply(x, paste, character(1), collapse = sep)
}


# Join lots of vectors together element-wise, removing extra whitespace.
smash <- function(...) {
    # 1. Join ... element-wise.
    j <- paste(...)

    # 2. In each element, compress multiple and trailing whitespace..
    trimws(gsub(pattern = "\\s+", replacement = " ", x = j))
}


# This is R4.0.0's deparse1() for versions before that. It also has a reversing option.
codify <- function(x, rev = FALSE) {
    sapply(x,
           function(col) {
               if (rev) { col <- rev(col)}

               paste(deparse(col, width.cutoff = 500L), collapse = " ")
           })
}


# Given a vector with many elements, prints some from the head, some from the
# tail, and skips the excess in the middle.
fold_middle <- function(vec, n = 2) {
    if (n < 2) {
        n <- 2  # A 'middle' needs to exist.
    }

    if (length(vec) <= n) {
        return(paste(vec, collapse = ", "))
    }

    num_head <- floor(n / 2)    # If an odd number is given as n, prefer to show
    num_tail <- ceiling(n / 2)  # more in the tail than in the head.

    head_idx <- 1:num_head
    tail_idx <- (length(vec) - (num_tail - 1)):length(vec)

    sprintf("%s...\f[ Skipping %s ]\f...%s",
            paste(vec[head_idx], collapse = ", "),
            cli::pluralize("{length(vec) - n} column{?s}"),
            paste(vec[tail_idx], collapse = ", "))
}


# Turn a list of words into a fuzzy regex
#
# A fuzzy regex is one that will match search terms in any order by using PERL
# lookaround. This can be very slow, but is often worth the cost to get more
# complete results.
fuzzy_needle <- function(vec) {
    words <- unique(unlist(strsplit(vec, "\\s+")))

    groups <- sapply(words, function(x) paste0("(?=.*", x, ")"), USE.NAMES = FALSE)

    paste0(groups, collapse = "")
}


has_class <- function(obj, classname) {
    any(classname %in% class(obj))
}


# Escape braces in glue() by doubling them
# https://glue.tidyverse.org/#a-literal-brace-is-inserted-by-using-doubled-braces
esc_braces <- function(str) {
    str <- gsub(pattern = "{", replacement = "{{", fixed = TRUE, x = str)
    str <- gsub(pattern = "}", replacement = "}}", fixed = TRUE, x = str)

    return(str)
}
