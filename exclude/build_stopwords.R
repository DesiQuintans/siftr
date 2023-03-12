# Building stopword list
library(stopwords)
library(stringr)


get_words <- function(source) {
    sapply(c("snowball", "stopwords-iso", "smart", "marimo", "nltk"),
           function(src) {
               stopwords::stopwords(source = src)
           })
}

sw <- get_words()

all_words <- unlist(sw)

tbl <- table(all_words)

# Words that occurred in at least 3 of 5 lists.
common_words <- names(tbl[tbl >= 3])

# https://stackoverflow.com/a/3695700/5578429
# common_words <- Reduce(intersect, sw)


# Words that should be kept because they are pertinent to data analysis
kept_words <- c("until", "while", "against", "between", "during", "before", "after", "above", "below", "up", "down", "no", "on", "off", "over", "under", "once", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "not", "only", "same", "again", "many", "who")

sift_stopword_list <- setdiff(common_words, kept_words)
stopwords_sift <-
    unique(sort(c(str_to_lower(sift_stopword_list), str_to_sentence(sift_stopword_list))))

usethis::use_data(stopwords_sift, overwrite = TRUE)


test <- "We all know that this is a (mostly) meaningless sentence, we sure do."
stopword_list <- stopwords(language = "en", source = "snowball")

library(stopwords)



remove_words <- function(str, stopwords) {
    orig <- unlist(strsplit(str, "[[:space:]]|(?=[[:punct:]])", perl = TRUE))
    x <- gsub(pattern = "[[:punct:]]", replacement = "", x = tolower(orig))

    is_stopword <- x %in% stopwords

    res <- paste(orig[!is_stopword], collapse = " ")
    res <- gsub("\\s+", " ", res)  # Squish spaces
    res <- gsub("\\s+([[:punct:]])", "\\1", res)  # Remove space before punctuation
    res <- gsub("(\\w)([([{])\\s+", "\\1 \\2", res)  # For left-brackets, fix spaces

    return(res)
}

removeWords(test, stopwords(language = "en", source = "snowball"))
remove_words(test, stopwords(language = "en", source = "snowball"))

res <-
    bench::mark(
        removeWords(janeaustenr::emma, stopwords(language = "en", source = "snowball")),
        remove_words(janeaustenr::emma, stopwords(language = "en", source = "snowball")),
        check = FALSE,
        min_time = Inf,
        max_iterations = 3
    )

res[2:8]
