# sift() maintains its hash and dictionary lists in a closure, prooty fancy!
closure.sift <- function() {
    current_hash <- list()  # Stores named hashes of dataframes.
    current_dict <- list()  # Stores named dataframe dictionaries.



    # ---- sift() begins here -------------------------
    s <- function(.df, ..., .dist = 0, .rebuild = FALSE) {
        # The df is passed to internal functions as a Char string, then evaluated later.
        df_name <- deparse(substitute(.df))


        # ---- 1. Ensure that df is a dataframe ------------------------------------------

        if (!is.data.frame(.df)) {
            cli::cli_alert_danger( msg_sift("not a df", 1, df_name))
            cli::cli_alert_warning(msg_sift("not a df", 2))
            cli::cat_line()
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


        # ---- 2. Convert ... into a query and perform a search --------------------------

        query <- nse_dots(...)

        if (identical(query, character(0))) {
            # If dots is empty, then return the dictionary itself.

            cli::cli_alert_info(msg_sift("report dims", 1,
                                         length(unique(dict[["varname"]])),
                                         fold(dict[["varname"]], n = 50)),
                                wrap = TRUE)
            cli::cat_line()

            return(invisible(dict))
        } else if (length(query) == 1) {
            # If dots has just one item in it, then treat it as an agrep() search, which
            # is possibly a regular expression.

            candidates <-
                agrep(query, dict$haystack, ignore.case = TRUE, value = FALSE,
                      fixed = FALSE, max.distance = .dist)
        } else {
            # But if dots has more than one element, then use it to build a fuzzy search
            # with look-around.

            query <- fuzzy_needle(query)  # E.g. (?=.*gallon)(?=.*mileage)

            candidates <-
                # Fuzzy needle requires PERL regex, which agrep and aregexc don't support.
                grep(query, dict$haystack, ignore.case = TRUE, perl = TRUE)
        }


        # ---- 3. Display the results of the sift ----------------------------------------

        # First, determine how many results to show based on the sift_limit option.
        total_results  <- length(candidates)
        excess_results <- 0

        if (total_results > options_sift("sift_limit")) {
            excess_results <- total_results - options_sift("sift_limit")
            shown_candidates <- candidates[1:options_sift("sift_limit")]
        }

        # If there are no matches (integer(0)), this returns a dataframe with no rows.
        found <- dict[shown_candidates, ]

        if (length(shown_candidates) < 1) {
            # No matches.
            cli::cli_alert_danger(msg_sift("no matches", 1, query, .dist))

            if (grepl("\`", query)) {
                # Backtick was found. This can happen if a regex was passed as a bare name.
                cli::cli_alert_info(msg_sift("no matches", 2), wrap = TRUE)
            }

            cli::cli_alert_info(msg_sift("no matches", 3, .dist), wrap = TRUE)
            cli::cat_line()
        } else {
            # There's at least one match. I use display_row() to print every row of the return dataframe.
            apply(X = found, MARGIN = 1, FUN = display_row)

            plur <- plural(length(shown_candidates))
            cli::cat_line()
            cli::cli_alert_success(msg_sift("n results", 1,
                                            plur$were,
                                            total_results,
                                            plur$s, query))

            if (excess_results > 0) {
                cli::cli_alert_warning(msg_sift("over limit", 1,
                                                options_sift("sift_limit"),
                                                plural(excess_results)$was))
            }
        }

        # Return a dataframe of all results, not just the ones that were shown.
        return(invisible(dict[candidates, ]))
    }

    return(s)
}


#' Fuzzily search dataframe column names, labels, and factor levels to find variables
#'
#' When working with dataframes that are hundreds of columns wide, it can be hard to find
#' which column contains the variable that you need. This function gives you interactive,
#' flexible searching through a dataframe, suggesting columns and some basic summary stats
#' about what they contain.
#'
#' @param .df (Dataframe) A dataframe to search through.
#' @param ... (Dots) Search query. See Details for more information.
#' @param .dist (Numeric) The maximum distance allowed for a match when searching
#'      fuzzily. See `max.distance` in [agrep()]. In short: a proportion is the fraction of
#'      the pattern length that can be flexible (e.g. `0.1` = 10% of the pattern length),
#'      whereas whole integers > 0 are the number of characters that can be flexible.
#' @param .rebuild (Logical) If `TRUE`, then force a dictionary rebuild even if it normally
#'      would not be triggered.
#'
#' @details You have two ways to search with `sift()`: _fuzzy search_ or _look-around search_.
#'
#' - **Fuzzy search** lets you get results that are close, but not exact, matches to your
#'    query. For example, `"cars"` can match `"cats"`. This is useful because real-world
#'    labelling is not always perfect; a query for `"baseline"` will match `"baseline"`
#'    or `"base line` or even OCR errors or typos like `"basellne"`. Fuzzy search needs to
#'    be opted-into by setting the `.dist` argument to a value > 0.
#' - **Look-around search** matches keywords regardless of the order you give them. This
#'    means that you can ask for `cow, number` and get a match for `"number of cows"`.
#'    This is useful when you have an idea of what keywords should be in a variable label,
#'    but not how those keywords are actually used or phrased. _Note that this is not
#'    a fuzzy search, so the keywords have to match exactly._
#'
#' The kind of search that is performed depends on how you supply your query to `...`:
#'
#' - **Pass one bare name:** Fuzzy search with a fixed string. Example: `sift(df, cow, .dist = 1)`
#' - **Pass one string:** Fuzzy search with a regular expression. Example: `sift(df, "cow.*?number", .dist = 1)`
#' - **Pass one bare name or string without changing `.dist`:** Non-fuzzy search. Example: `sift(df, cow)`
#' - **Pass more than one item:** (either as a vector or in multiple elements of `...`) Look-around
#'      non-fuzzy search with fixed strings.
#'
#' @return If `...` is empty, return the full data dictionary for `df`. If the query was
#'      matched, invisibly return the rows of the data dictionary that matched. If the
#'      query was not matched, invisibly return the data dictionary with no rows (but
#'      all columns).
#'
#' @export
#'
#' @examples
#' # sift(mtcars_lab)
#' # sift(mtcars_lab, mileage)
#' # sift(mtcars_lab, "date|time", arrival)
#'
#' @md
sift <- closure.sift()
