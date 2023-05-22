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


# For a multi-element vector, print the first n unique items and announce how many
# others remain.
# If n > length(vec), just print the whole thing.
fold <- function(vec, n = 2) {
    vec <- unique(vec)

    items <- vec[1:n]
    items <- items[!is.na(items)]

    remain <- sum(!match(vec, items, nomatch = FALSE), na.rm = TRUE)
    remain_str <- ifelse(remain > 0, sprintf(", and %i more", remain), "")

    paste0(paste(items, collapse = ", "), remain_str)
}


# For a multi-element vector 1:4, report it as "1, 2, 3, or 4".
fold_or <- function(vec, word = "or") {
    v <- as.character(vec)
    v[length(v)] <- paste(word, v[length(v)])
    return(paste(v, collapse = ", "))
}



# Turn a list of words into a fuzzy regex
#
# A fuzzy regex is one that will match search terms in any order by using PERL
# lookaround. This can be very slow, but is often worth the cost to get more
# complete results.
#
# @param vec (Character) A string containing space-separated keywords to search for.
#
# @return A string where each word has been wrapped as a lookaround term.
#
# @examples
# \dontrun{
# fuzzy_needle("network centrality")
# #> [1] "(?=.*network)(?=.*centrality)"
# }
fuzzy_needle <- function(vec) {
    words <- unique(unlist(strsplit(vec, "\\s+")))

    groups <- sapply(words, function(x) paste0("(?=.*", x, ")"), USE.NAMES = FALSE)

    paste0(groups, collapse = "")
}


has_class <- function(obj, classname) {
    any(classname %in% class(obj))
}


# Truncate long strings with ellipsis
# shorten(state.name, 7)
shorten <- function(x, width) {
    x <- as.character(x)
    is_long <- nchar(x) > width
                                               # Makes room for ellipsis
    x[is_long] <- paste0(substr(x[is_long], 1, width - 1),
                         cli::symbol["ellipsis"])

    return(x)
}






# Plural forms
plural <- function(n) {
    if (n == 1) {
        other <- "other"
        s     <- ""
        was   <- "was"
    } else {
        other <- "others"
        s     <- "s"
        was   <- "were"
    }

    return(invisible(list(other = other,
                          others = other,
                          s = s,
                          was = was,
                          were = was)))
}



