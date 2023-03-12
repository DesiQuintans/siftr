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



# Reverse the order of elements in a string.
# Used [[1]] instead of unlist() because it (might be?) faster.
rev_string <- function(x, sep = ", ") {
    paste(rev(strsplit(x, split = sep)[[1]]), collapse = sep)
}



# This is R4.0.0's deparse1() for versions before that. It also has a reversing option.
codify <- function(x, rev = FALSE) {
    sapply(x,
           function(col) {
               if (rev) { col <- rev(col)}

               paste(deparse(col, width.cutoff = 500L), collapse = " ")
           })
}



# Get the n most common values in a vector and report them with their frequencies.
summ_mode <- function(x, n = 2) {
    if ("haven_labelled" %in% class(x)) {
        # For vectors with value labels, it causes the error
        #     Error: Can't convert `x` <haven_labelled> to <character>.
        x <- haven_to_factor(x)
    }

    if (length(unique(x)) == length(x)) {
        # All elements are unique, so there is no mode.
        return("All unique")
    }

    items <- sort(table(x), decreasing = TRUE)[1:n]

    # If n is larger than the number of unique values, then it returns extra vector
    # elements that are NA. Only return the ones that are not NA.
    items <- items[!is.na(items)]

    result <- paste(sprintf("%s (%i)", names(items), as.integer(items)), collapse = ", ")

    return(result)
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



# This rounds AND truncates a number to length.
round_to <- function(x, digits = 2) {
    nums_as_char <- trimws(format(round(x, digits = digits), nsmall = digits))
    as.numeric(nums_as_char)
}



# This builds median and IQR
summ_iqr <- function(vec) {
    if (is.numeric(vec) == FALSE || "haven_labelled" %in% class(vec)) {
        # IQR can't be calculated for non-numeric vectors. Crucially, haven_labelled
        # vectors should be treated as non-numeric data too (they're really factors that
        # haven't been converted into factors.)
        return(NA_character_)
    }

    tuk <- stats::fivenum(vec, na.rm = TRUE)

    sprintf("%.1f (%.1f) %.1f", tuk[2], tuk[3], tuk[4])
}



# Turn a list of words into a fuzzy regex
#
# A fuzzy regex is one that will match search terms in any order by using PERL
# lookaround. This is very slow, but often worth the cost to get more complete
# results.
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



# Without labelled or haven loaded, trying to do any type coercion with a value-labelled
# column could bring up errors like: Error: Can't convert `x` <haven_labelled> to <character>.
# This function is used in those places to express value-labelled columns as factors.
haven_to_factor <- function(x, ...) {
    lab  <- attr(x, "label")
    levs <- attr(x, "labels")
    labs <- sprintf("%i (%s)", levs, names(levs))  # Prefix values on labels.

    fac <- factor(as.character.default(x),  # Specifically telling R not to look for a
                                            # generic as.character.haven_labelled(), that
                                            # it's okay to use the default method.
                  levels = levs,
                  labels = labs,
                  ...)

    attr(fac, "label") <- lab

    return(fac)
}


has_class <- function(obj, classname) {
    classname %in% class(obj)
}


# Truncate long strings with ellipsis
# shorten(state.name, 7)
shorten <- function(x, width) {
    x <- as.character(x)
    is_long <- nchar(x) > width

    x[is_long] <- paste0(substr(x[is_long], 1, width - 1),  # width-1 to make room for ...
                         cli::symbol["ellipsis"])

    return(x)
}
