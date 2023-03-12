#' Set and get options related to how sift() runs.
#'
#' - `sift_loudly` (Logical; default `TRUE`) --- Should optional informative messages be shown?
#' - `sift_stopwords` (Logical; default `TRUE`) --- Should stopwords be removed from `sift()`
#'    console output? This makes the output terser, so it's good for removing low-value
#'    words from wordy labels. The list of stopwords is an included dataset called
#'    `stopword_sift`.
#' - `sift_limit` (Integer; default `10`) --- How many matches should `sift()` print? This
#'    is meant to save you from accidentally printing a summary that is hundreds of columns long.
#' - `sift_guessmax` (Integer; default `1000`) --- What is the maximum number of elements that
#'    gets randomly sampled from each column to build summary stats? This includes stats like
#'    frequent values and random previews.
#'
#' @param key (String) The name of an option.
#' @param val (Optional) A new value for the option, if you want to change it.
#'
#' @return The option's value.
#' @export
#'
#' @examples
#' # options_sift("sift_loudly")  # Returns the option's current value
#'
#' # options_sift("sift_loudly", FALSE)  # Change the value to something else.
#'
#' # Options set in this function are set in R's options() interface
#' # options("sift_loudly")
#' # getOption("sift_loudly")
#' @md
options_sift <- function(key = c("sift_loudly", "sift_terse", "sift_limit", "sift_guessmax"), val = NULL) {
    default_setting <- list(
        sift_loudly   = TRUE,
        sift_terse    = FALSE,
        sift_limit    = Inf,
        sift_guessmax = 1000
    )

    if ((key %in% names(default_setting)) == FALSE) {
        cli::cli_abort(c(
            "x" = paste0('"', key, '"', " is not one of sift's options."),
            "i" = paste0("Did you mean ", fold_or(names(default_setting)), "?\n")))
    }

    if (is.null(getOption(key))) {
        options(default_setting[key])  # Not set, give it the default setting.
    }

    if (!is.null(val)) {
        # Set, but may need updating.

        # I am passing options in lists because it's how you get dynamically-named lists.
        # Doing options(key = val) just makes a new option with name 'key'.

        opt <- list()
        opt[key] <- val

        options(opt[key])
    }

    return(getOption(key))
}
