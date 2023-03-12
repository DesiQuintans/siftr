
#' Fuzzily search column names and labels
#'
#' When working with dataframes hundreds of columns wide, it can be hard to find which
#' column contains a particular measurement or characteristic. This function lets you
#' fuzzily search a dataframe's column names (`colnames()`), column labels (the `attr()`
#' named `"label"`), value labels (the `attr()` named `"labels"`), and factor
#' levels (`levels()`) for a match. It also reports appropriate summary statistics like:
#'
#' - Variable type
#' - Number of unique elements
#' - Percentage of the vector that is `NA` or `NaN`
#' - Range (min to max)
#' - Mode (most common value(s))
#' - Median (50th percentile value)
#'
#'
#'
#' @param df (Dataframe) The dataframe
#' @param query (Character) A string (or regular expression) to search for.
#' @param dist (Numeric) Maximum string distance. Either an integer or a double; see
#'     `max.distance` in `base::agrep()`. Set to `0` to force an exact match.
#'
#' @return Prints out matching name & label combinations, and invisibly returns the same.
#' @export
#'
#' @examples
#'
#' sift(iris_labelled_hmisc, "pal.width")
#' # Note fuzzy searching gets both "pal.width" and "tal.width"
#'
#' #> Sepal.Width | type: numeric | Uniq: 23 | NA %: 0
#' #>     Width of sepals.
#' #>     range: 2-4.4 | mode: 3 | median: 3
#' #> Petal.Width | type: numeric | Uniq: 22 | NA %: 0
#' #>     Width of petals.
#' #>     range: 0.1-2.5 | mode: 0.2 | median: 1.3
#'
#' sift(iris_labelled_hmisc, "pal.width", dist = 0)
#' # dist = 0 forces an exact match
#'
#' #> Sepal.Width | type: numeric | Uniq: 23 | NA %: 0
#' #>     Width of sepals.
#' #>     range: 2-4.4 | mode: 3 | median: 3
#'
#' sift(iris_labelled_hmisc, "versicol")
#' # The columns' labels are also searched.
#'
#' #> Species | type: factor | Uniq: 3 | NA %: 0
#' #>     Species of iris: setosa, versicolor, virginica
#' #>     mode: setosa, versicolor, and 1 other
#'
#' @section Authors:
#' - Desi Quintans (<http://www.desiquintans.com>)
#' @md
#' @importFrom magrittr %>%
sift <- function(df, query, dist = 0.1) {
    dict <- build_dict(df)
    # df_
    #
    #
    #
    #
    #
    # get_label <- function(item) {
    #     result <- attr(item, "label")
    #
    #     if (is.null(result)) {
    #         return("")
    #     } else {
    #         return(stringr::str_trim(result))
    #     }
    # }
    #
    # fold <- function(vec, n = 2) {
    #     if (length(vec) >= n) {
    #         # Need to truncate the vector and show remainder.
    #         paste(
    #             stringr::str_flatten_comma(vec[1:n]),
    #             "and", length(vec) - n, "others"
    #         )
    #     } else {
    #         # Whole vector can be shown.
    #         stringr::str_flatten_comma(vec)
    #     }
    # }
    #
    # round_to <- function(x, digits = 2) {
    #     nums_as_char <- trimws(format(round(x, digits = digits), nsmall = digits))
    #     as.numeric(nums_as_char)
    # }
    #
    # Mode <- function(x, na.rm = FALSE) {
    #     if (na.rm) {
    #         x = x[!is.na(x)]
    #     }
    #
    #     ux <- unique(x)
    #     tab <- tabulate(match(x, ux))
    #     result <- ux[tab == max(tab)]
    #
    #     return(result)
    # }
    #
    # attr_name  <- stringr::str_trim(colnames(df))
    # attr_label <- sapply(df, get_label, USE.NAMES = FALSE)
    #
    # names(attr_label) <- NULL
    #
    # # This is what gets searched to find matching columns
    # attr_joined <- stringr::str_trim(paste(attr_name, attr_label))
    #
    # out <- agrep(query, attr_joined, ignore.case = TRUE, value = FALSE, fixed = FALSE,
    #              max.distance = dist)
    #
    # purrr::pwalk(list(attr_name[out], attr_label[out], df[out]),
    #              function(colname, lab, vec) {
    #
    #
    #                  cli::cli({
    #                      cli::cli_text(colname,
    #                                    cli::col_silver(
    #                                        glue::glue(
    #                                            "",
    #                                            "type: {fold(class(vec), 2)}",
    #                                            "Uniq: {length(unique(vec))}",
    #                                            "NA %: {round_to(sum(is.na(vec))/length(vec)*100)}",
    #                                            .sep = " | "
    #                                        )
    #                                    )
    #                      )
    #
    #                      cli::cli_div(class = "tmp",
    #                                   theme = list(.tmp = list("margin-left" = 4,
    #                                                            "margin-right" = 4)))
    #                      if (lab != "") {
    #                          cli::cli_text(cli::col_silver(lab))
    #                      }
    #
    #                      if (is.numeric(vec)) {
    #                          cli::cli_text(cli::col_silver(
    #                              glue::glue("range: {paste(round_to(range(vec, na.rm = TRUE)), collapse = '-')}",
    #                                         "mode: {fold(Mode(vec, na.rm = TRUE))}",
    #                                         "median: {round_to(median(vec, na.rm = TRUE))}",
    #                                         .sep = " | "
    #                              )
    #                          ))
    #                      } else {
    #                          cli::cli_text(cli::col_silver(
    #                              glue::glue("mode: {fold(Mode(vec, na.rm = TRUE))}",
    #                                         .sep = " | "
    #                              )
    #                          ))
    #                      }
    #                  })
    #              }
    # )
    #
    # return(invisible(list(cols = attr_name[out],
    #                       labels = attr_label[out])))
}
