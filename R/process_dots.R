
# Processing 'dots' into package names ------------------------------------
# Copied from DesiQuintans/librarian ======================================

# How many items are in dots?
dots_length <- function(...) {
    length(eval(substitute(alist(...))))
}



# Did the user pass arguments inside dots?
dots_is_empty <- function(...) {
    dots_length(...) <= 0
}



# Is the 1st 'dots' arg a character vector with length > 1?
dots1_is_pkglist <- function(...) {
    result <- tryCatch(eval(..1),
                       error   = function(e) return(FALSE),
                       warning = function(w) return(FALSE))

    any(
        # A character vector with more than one element.
        (is.vector(result) & is.character(result) & length(result) > 1),
        # A character vector and no other items are provided in dots.
        (is.vector(result) & is.character(result) & dots_length(...) == 1)
    )
}



# Convert dots to package names
nse_dots <- function(...) {
    if (dots_is_empty(...)) {
        return(character(0))
    }

    if (dots1_is_pkglist(...)) {
        # Accepting a character vector of package names makes Librarian's
        # functions more versatile for programming.
        dots <- ..1
    } else {
        dots <- as.character(eval(substitute(alist(...))))
    }

    dots <- gsub("\\s", "", dots)  # Closes https://github.com/DesiQuintans/librarian/issues/13

    dots <- unique(dots)
    dots <- dots[nchar(dots) > 0]

    return(dots)
}
