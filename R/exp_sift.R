# sift() maintains its hash and dictionary lists in a closure, prooty fancy!
closure.sift <- function(search_where = NULL) {
    stopifnot(!is.null(search_where))

    current_hash <- list()  # Stores named hashes of dataframes.
    current_dict <- list()  # Stores named dataframe dictionaries.


    # ---- sift() begins here -------------------------
    s <- function(.df, ..., .dist = 0, .rebuild = FALSE) {
        # The df is passed to internal functions as a Char string, then evaluated later.
        df_name <- deparse(substitute(.df))


        # ---- 1. Ensure that df is a dataframe ------------------------------------------

        # Does it exist at all?
        tryCatch(is.data.frame(.df), error = function(e) {
            cli::cli_abort(
                message = c("No object named {.var {df_name}} was found.",
                            " " = "Does it exist? Is its name correct?"),
                call    = NULL)
        })

        # Is it a dataframe?
        if (!is.data.frame(.df)) {
            cli::cli_abort(
                message = c("{.var {df_name}} is not a dataframe.",
                            " " = "{.pkg siftr} only searches through dataframes."),
                call    = NULL)
        }


        # ---- 2. Has df been sift()ed before? Has it changed since the last time? -------

        new_hash <- hash_obj(df_name, current_hash)

        if (.rebuild == TRUE || !identical(current_hash[[df_name]], new_hash[[df_name]])) {
            # The new hash doesn't match the one that's stored for this object.
            # Update the stored hash and dictionary in the closure.
            current_hash <<- new_hash
            current_dict <<- build_dictionary(df_name, current_dict)
        }

        dict <- current_dict[[df_name]]


        # ---- 3. Shortcut exit if no search is requested --------------------------------

        orig_query  <- nse_dots(...)

        if (identical(orig_query, character(0))) {
            # If dots is empty, then return the dictionary itself.

            # Report some of the variables in the dataframe.
            num_cols   <- length(unique(dict[["varname"]]))
            some_names <- fold_middle(dict[["varname"]], n = 50)
            cli::cli_inform(
                message = c("i" = "{.var {df_name}} has {num_cols} column{?s}:",
                            " " = "{some_names}.")
            )

            return(invisible(dict))
        }

        # ---- 4. If a search is needed, do one ------------------------------------------

        search_haystack <-
            switch(
                search_where,
                "all"     = dict$haystack,  # Searches colnames, col label, factor levels, unique values.
                "name"    = dict$varname,   # Searches colnames only.
                "desc"    = dict$var_lab,   # Searches col label only.
                "factors" = dict$lab_lvls   # Searches variable labels and factor labels.
            )


        if (length(orig_query) == 1) {
            # If dots has just one item in it, then treat it as an agrep() search, which
            # is possibly a regular expression.

            query <- orig_query

            candidates <-
                agrep(query, search_haystack, ignore.case = TRUE, value = FALSE,
                      fixed = FALSE, max.distance = .dist)
        } else {
            # But if dots has more than one element, then use it to build a fuzzy search
            # with look-around.

            if (.dist > 0) {

                cli::cli_inform(
                    message = c(
                        "An orderless search was performed, so {.arg .dist = {(.dist)}} was ignored.",
                        "To remove this warning, either remove {.arg .dist} or provide your query as a single character string."
                    )
                )
            }

            query <- fuzzy_needle(orig_query)  # E.g. (?=.*gallon)(?=.*mileage)

            candidates <-
                # Fuzzy needle requires PERL regex, which agrep and aregexc don't support.
                grep(query, search_haystack, ignore.case = TRUE, perl = TRUE)
        }


        # ---- 3. Display the results of the sift ----------------------------------------

        # First, determine how many results to show based on the sift_limit option.
        shown_candidates <- candidates
        total_results  <- length(candidates)
        excess_results <- 0

        if (total_results > options_sift("sift_limit")) {
            excess_results <- total_results - options_sift("sift_limit")
            shown_candidates <- candidates[1:options_sift("sift_limit")]
        }

        # If there are no matches (integer(0)), this returns a dataframe with no rows.
        found <- dict[shown_candidates, ]

        cli::cli_h1("Results for {.code {query}} in {.pkg {df_name}}")

        if (length(shown_candidates) >= 1) {
            # There's at least one match. I use display_row() to print every row of the return dataframe.
            apply(X = found, MARGIN = 1, FUN = display_row)
        }

        cli::cli_h2("Summary")

        if (length(shown_candidates) < 1) {
            # No matches.

            cli::cli_alert_danger("No matches found for query {.code {query}}.", wrap = TRUE)

            if (grepl("\`", query)) {
                # Backtick was found. This can happen if a regex was passed as a bare name.
                cli::cli_alert_info("If you're using a regular expression, pass it as a string.", wrap = TRUE)
            }

            if (length(orig_query) == 1) {
                cli::cli_alert_info("Try increasing {.arg .dist = {(.dist)}} to allow more distant matches.", wrap = TRUE)
            }
        } else {
            # `n results`   = c("There %s %i result%s for query `%s`."),
            #
            # `over limit`  = c("Only %1$s of them %2$s printed, set by options_sift(\"sift_limit\", %1$s)"),

            cli::cli_alert_success("Found {total_results} result{?s} for query {.code {query}}.", wrap = TRUE)

            if (excess_results > 0) {
                cli::cli_alert_warning(
                    "Only {length(shown_candidates)} of them {?was/were} printed, set by {.run options_sift(\"sift_limit\", {options_sift('sift_limit')})}.",
                    wrap = TRUE
                )
            }

            cli::cli_alert_info(
                "Use {.run View(.Last.value)} to view the full table of matches."
            )
        }

        cli::cat_line()

        # Return a dataframe of all results, not just the ones that were shown.
        return(invisible(dict[candidates, ]))
    }

    return(s)
}


#' Find relevant variables in a dataframe using fuzzy searches
#'
#' It can be hard to find the right column in a dataframe with hundreds or thousands of
#' columns. This function gives you interactive, flexible searching through a dataframe,
#' suggesting columns that are relevant to your query and showing some basic summary
#' stats about what they contain.
#'
#' @param .df (Dataframe) A dataframe to search through.
#' @param ... (Dots) Search query. Case-insensitive. See Details for more information.
#' @param .dist (Numeric) The maximum distance allowed for a match when searching
#'      fuzzily. See `max.distance` in [agrep()]. In short: a proportion is the fraction of
#'      the pattern length that can be flexible (e.g. `0.1` = 10% of the pattern length),
#'      whereas whole integers > 0 are the number of characters that can be flexible. `0` is
#'      an exact search.
#' @param .rebuild (Logical) If `TRUE`, then force a dictionary rebuild even if it normally
#'      would not be triggered. Rebuilds are triggered by changes to a dataframe's dimensions,
#'      its columns (names, types, order), and/or its count of `NA`s in each column.
#'
#' @details You have three ways to search with `sift()`: _exact search_, _fuzzy search_, or
#' _orderless search_ (also called _look-around search_).
#'
#' - **Exact search** looks for exact matches to your query. For example, searching for
#'    `"weight of"` will only match `weight of`.
#' - **Fuzzy search** gives you results that are close, but not exact, matches to your
#'    query. This is useful because real-world labelling is not always consistent or even
#'    correct, so using a fuzzy search for `"baseline"` will helpfully match `baseline` or
#'    `base line` or even OCR errors or typos like `basellne`.
#' - **Orderless search** matches keywords regardless of the order you give them. This
#'    means that you can ask for `cow, number` and get a match for `number of cows`.
#'    This is useful when you have an idea of what keywords should be in a variable label,
#'    but not how those keywords are actually used or phrased. _Note that this is not
#'    a fuzzy search, so the keywords have to match exactly._
#'
#' The search that's performed depends on `...` and `.dist`:
#'
#' - **Orderless search** is _always_ used when you pass more than one query term into `...`.
#' - **Exact search** is done when `.dist = 0`.
#' - **Fuzzy search** must be opted-into by setting the `.dist` argument to a value > 0. It
#'     is ignored in orderless searching.
#'
#' @return
#' Invisibly returns a dataframe. The contents of that dataframe depend on the query:
#'
#' - If `...` is empty, the full data dictionary for `df` is returned.
#' - If the query was matched, only returns matching rows of the data dictionary.
#' - If the query was not matched, return no rows of the dictionary (but all columns).
#'
#' @describeIn sift Search variable names, descriptive labels, factor labels, and unique values.
#'
#' @seealso [siftr::save_dictionary()], [siftr::options_sift()]
#'
#' @export
#'
#' @examples
#' \donttest{
#' sift(mtcars_lab)  # Builds a dictionary without searching.
#'
#' sift(mtcars_lab, .)  # Show everything up to the print limit (by default, 25 matches).
#'
#' sift(mtcars_lab, mileage)  # Exact search for "mileage".
#' sift(mtcars_lab, "above avg", .dist = 1)  # Fuzzy search (here, space -> underscore).
#'
#' sift(mtcars_lab, "na", "column")  # Orderless searches are always exact.
#'
#' sift(mtcars_lab, "date|time")  # Regular expression
#' sift(mtcars_lab, "cyl|gear", number)  # Orderless search with regular expression
#' }
#'
#' @md
sift <- closure.sift(search_where = "all")


#' @describeIn sift Only search variable names (i.e. column names).
#' @examples
#' \donttest{
#' sift.name(mtcars_lab, "car")  # Only searches variable names.
#' }
#' @export
sift.name <- closure.sift(search_where = "name")


#' @describeIn sift Only search the descriptive labels of variables.
#' @examples
#' \donttest{
#' sift.desc(mtcars_lab, "car")  # Only searches variable descriptions.
#' }
#' @export
sift.desc <- closure.sift(search_where = "desc")


#' @describeIn sift Only search factor labels. This includes "value labels", e.g. 'haven_labelled' types.
#' @examples
#' \donttest{
#' sift.factors(mtcars_lab, "manual")  # Only searches factor levels and value labels.
#' }
#' @export
sift.factors <- closure.sift(search_where = "factors")
