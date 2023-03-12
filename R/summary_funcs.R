# Fast approximate summary functions

# Should a statistic be approximated because the column is larger than the limit?
# Return randomly sampled indices (or all indices), a marker, and a logical.
should_approx <- function(x) {
    if (length(x) > options_sift("sift_guessmax")) {
        x         <- sort(sample(x       = seq_along(x),
                                 size    = options_sift("sift_guessmax"),
                                 replace = FALSE))
        mark      <- sprintf("%s ", cli::symbol["warning"])
        is_approx <- TRUE
    } else {
        x         <- seq_along(x)
        mark      <-  character(0)
        is_approx <- FALSE
    }

    return(list(indices = x, marker = mark, is_approx = is_approx))
}


# Randomly choose and show some unique values
some_values <- function(x, n = 3) {
    pool <- should_approx(x)

    item_width <- floor((options("width")[[1]] - 15) / n)  # Truncate to one console line
    uniques <- unique(x[pool$indices])

    items <- shorten(uniques[1:min(length(uniques), n)], item_width)

    paste0(pool$marker, paste0(items, collapse = ", "))
}


min_max <- function(x) {
    x <- x[!is.na(x)]

    ifelse(is.numeric(col) & !has_class(col, "haven_labelled"),
           paste(min(col), max(col), collapse = " - "),
           NA_character_)
}
