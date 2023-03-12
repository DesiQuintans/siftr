

#' List of stopwords for making terse labels
#'
#' This is a list of stopwords that was generated from `stopwords::stopwords(source = src)`
#' where `src` is one of `c("snowball", "stopwords-iso", "smart", "marimo", "nltk")` and
#' language is `"en"`. I kept any word that appeared in at least 3 out of 5 of those lists,
#' and then re-added these words that are pertinent to data analysis: "until", "while",
#' "against", "between", "during", "before", "after", "above", "below", "up", "down", "no",
#' "on", "off", "over", "under", "once", "when", "where", "why", "how", "all", "any",
#' "both", "each", "few", "more", "most", "not", "only", "same", "again", "many", "who". I
#' duplicated the list and made the first half in lowercase, and the second half in sentence
#' case.
#'
#' @format A character vector with 338 elements.
#' @source <https://github.com/koheiw/stopwords>
#' @md
"stopwords_sift"


#' Labelled version of mtcars
#'
#' This is mtcars with value labels, variable labels (in `vs` only), some transformation
#' to factor (`car` and `am`), and an added Logical column (`above_avg`).
#'
#' @format A dataframe with 13 columns and 32 rows.
#'
#' @source `mtcars`
#' @md
"mtcars_lab"
