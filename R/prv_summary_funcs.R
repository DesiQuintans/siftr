# Fast approximate summary functions

# Randomly choose and show some unique values from a variable.
#
#
#
# @param x (Vector) A vector.
#
# @return A Character string.
# @md
some_uniques <- function(x) {
    # If it's a haven_labelled vector, I want to show it as a factor that
    # has both the values and the labels together.
    if (has_class(x, "haven_labelled")) {
        x <- haven_to_factor(x)
    }

    # 1. Sample elements from the variable.
    pool <- should_approx(x)

    uniques <- as.character(sample(unique(x[pool$indices])))
    uniques <- uniques[!is.na(uniques)]  # cli::ansi_collapse() cannot handle NAs.

    if (length(uniques) == 0) {
        # Length can be zero if the column was entirely NAs.
        return(trimws(paste(pool$marker, "NA")))
    }

    # Avoiding an issue with Excel where cells are limited to 32k characters. Probably
    # smart to limit the length of this output anyway so that the haystack being searched
    # is not too long.
    charlen <- cumsum(nchar(uniques))   # Running count of character length
    uniques <- uniques[charlen <= 500]  # All elements until the 500th character.

    return(trimws(paste(pool$marker,
                     cli::ansi_collapse(uniques, width = Inf,
                                        style = "head", last = ", "))))
}


# Are all elements of the vector identical?
#
# Up to 30x faster than `length(unique())`, with 1/5th memory allocation.
# <https://gist.github.com/DesiQuintans/0607047ba767469c870a3149b1f78cfe>
# Although it's very fast (6e6 doubles takes 50 ms, 6e6 strings takes 200 ms),
# it still has to run on each column, and there may be hundreds of those. It
# therefore randomly samples the vector once it reaches `sift_guessmax`'s limit.
#
# @param x (Vector) A vector.
# @param na.rm (Logical) If `TRUE`, remove `NA`s.
#
# @return A logical.
# @md
invariant <- function(x) {
    # Source: https://stackoverflow.com/a/59067398/5578429

    if (typeof(x) %in% c("list")) {
        # I don't want to go into the rabbit hole of comparing list cols.
        return(NA_character_)
    }

    pool <- should_approx(x)

    y <- x[pool$indices]
    y <- y[!is.na(y)]

    if (length(y) == 0 || all(y[1] == y)) {
        # Length can be zero if the column was entirely NAs.
        return(trimws(paste(pool$marker, "Yes")))
    } else {
        return(trimws(paste(pool$marker, "No")))
    }
}



# Choose the most informative variable type to show
#
# Almost all variable types can be named from their [typeof()], except
# for factor variables which are given the [class()] of 'factor'. Likewise,
# objects with class `haven_labelled` have an underlying type, and both the
# class and type are important to show.
#
# @param x (Vector) A vector.
#
# @return Character.
# @md
coltype <- function(x) {
    #   class               typeof
    #
    #   * factor            integer
    #   * haven_labelled    * integer
    #   numeric             * double
    #   integer             * integer
    #   logical             * logical
    #   character           * character

    if (has_class(x, "factor")) {
        ordered <- ""
        if (is.ordered(x)) {
            ordered <- " (ord.)"
        }

        return(sprintf("factor %s%i%s", cli::symbol$times, length(levels(x)), ordered))
    }

    if (has_class(x, "haven_labelled")) {
        return(sprintf("int (hvn_lbl) %s%i", cli::symbol$times, length(attr(x, "labels"))))
    }

    return(typeof(x))
}
