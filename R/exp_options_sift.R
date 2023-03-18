
#' Set and get options related to how [sift()] runs.
#'
#' - `sift_limit` (Integer; default `25`)
#'     - How many matches should [sift()] print? This saves you from accidentally printing
#'       a summary that is hundreds of columns long.
#' - `sift_guessmax` (Integer; default `1000`)
#'     - Running summary statistics on very large dataframes (hundreds of columns, millions
#'       of rows) can take a long time. This option controls the point at which [sift()]
#'       decides that a column has too much data in it to use as-is, and starts randomly
#'       sampling from it instead. For any dataframe with `nrow() <= guessmax`, the entirety
#'       of each column will be used for summary stats like "Missing %" and "Peek at
#'       unique values". Above this row count, `guessmax` elements of each column will be
#'       randomly sampled without replacement to make these stats, and a warning glyph
#'       will be shown alongside those stats.
#'
#' @param key (String) The name of an option.
#' @param val (Optional) A new value for the option, if you want to change it.
#'
#' @return The option's value.
#' @export
#'
#' @examples
#' # options_sift("sift_limit")  # Returns the option's current value
#'
#' # options_sift("sift_limit", 100)  # Change the value to something else.
#'
#' # Options set in this function are set in R's options() interface
#' # options("sift_limit")
#' # getOption("sift_limit")
#' @md
options_sift <- function(key = c("sift_limit", "sift_guessmax"), val = NULL) {
    default_setting <- list(
        sift_limit    = 25,
        sift_guessmax = 1000
    )

    if ((key %in% names(default_setting)) == FALSE) {
        cli::cli_abort(c(
            "x" = msg_sift("not option", 1, key),
            "i" = msg_sift("not option", 2, fold_or(names(default_setting)))
            ))
    }

    if (is.null(getOption(key))) {
        # Not set, give it the default setting.
        options(default_setting[key])
    }

    if (!is.null(val)) {
        # Set, but may need updating.

        # I am passing options in lists because it's how you get dynamically-named options.
        # Doing options(key = val) just makes a new option with name 'key'.

        opt <- list()
        opt[key] <- val

        options(opt[key])
    }

    return(getOption(key))
}
