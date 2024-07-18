

#' View all matches from the most recent sift
#'
#' This is an alias for `utils::View(.Last.result)`, but its stores the last
#' sift result so that it's accessible even if you've done other things
#' since then.
#'
#' It returns the complete table of matches, i.e. even if there were too many
#' results to print to the console, all results are visible here. If run in
#' RStudio, it will open the results in the Viewer pane so that you can search,
#' filter, resort, etc.
#'
#' @return
#' Invisibly returns a dataframe.
#'
#' @export
#' @md
last.sift <- function() {
    result <- get("last_sift", envir = .siftr_env)
    deets  <- get("last_query", envir = .siftr_env)

    if (identical(data.frame(), result)) {
        # No sifts have been done.
        cli::cli_inform(
            message = c(
                "x" = "No {.fn sift}s have been performed yet."
            ))

        return(invisible(data.frame()))
    }

    if (nrow(result) == 0) {
        # A sift has been performed, but there were no results.
        cli::cli_inform(
            message = c(
                "i" = "The last query was {.val {deets$query}} in the {deets$loc} of {.var {deets$df}}.",
                "x" = "There were 0 matches out of {deets$total} variable{?s}.",
                " " = "Showing the empty data frame anyway."))
    } else {
        cli::cli_inform(
            message = c(
                "i" = "The last query was {.val {deets$query}} in the {deets$loc} of {.var {deets$df}}.",
                "v" = "There {cli::qty({deets$matches})} {?was/were} {deets$matches} match{?es} out of {deets$total} variable{?s}."))
    }

    # Retrieves the RStudio version of View() if it exists, otherwise gets the
    # regular utils::View().
    # https://stackoverflow.com/a/48242386/5578429
    myView <- function(x, title) {
        get("View", envir = as.environment("package:utils"))(x, title)
    }

    myView(result[, !(names(result) %in% "haystack")] , "Last sift")
    return(invisible(result))
}
