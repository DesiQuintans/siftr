# User-facing messages, collected here for easy editing/tone consistency.
msg_sift <- function(entry, i = 1, ...) {
    text <- list(
        `not a df`    = c("'%s' is not a dataframe.",
                          "sift() only searches through dataframes."),

        `report dims` = c("Dictionary has %i columns: %s."),

        `no matches`  = c("No matches found for query '%s' with .dist = %.2f.",
                          "If you're using a regular expression, pass it as a string.",
                          "Try increasing '.dist = %.2f' to allow more distant matches."),

        `over limit`  = c("In addition, %i other column%s matched too.",
                          "To show more results, increase `options_sift(\"sift limit\", %i)`."),

        `building`    = c("Building dictionary for '%s'"),

        `built`       = c("Dictionary was built in %s.")
        )
    return(sprintf(text[[entry]][i], ...))
}
