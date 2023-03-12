# Test hashing packages for speed
library(dplyr)
library(bench)

# Rows: 181,361. Cols: 110. Size: 92 MB
df <- readr::read_csv("exclude/female_players.csv")

sep <- function(x) {
    if (is.numeric(x) == FALSE || "haven_labelled" %in% class(x)) {
        # IQR can't be calculated for non-numeric vectors. Crucially, haven_labelled
        # vectors should be treated as non-numeric data too (they're really factors that
        # haven't been converted into factors.)
        return(NA_character_)
    }
    x <- x[!is.na(x)]
    q <- quantile(x, c(0.25, 0.50, 0.75))
    sprintf("%.1f %.1f (%.1f) %.1f %.1f", min(x), q[1], q[2], q[3], max(x))
}

tuk <- function(x) {
    if (is.numeric(x) == FALSE || "haven_labelled" %in% class(x)) {
        # IQR can't be calculated for non-numeric vectors. Crucially, haven_labelled
        # vectors should be treated as non-numeric data too (they're really factors that
        # haven't been converted into factors.)
        return(NA_character_)
    }

    y <- fivenum(x)

    sprintf("%.1f %.1f (%.1f) %.1f %.1f", y[1], y[2], y[3], y[4], y[5])
}

summ <- function(x) {
    if (is.numeric(x) == FALSE || "haven_labelled" %in% class(x)) {
        # IQR can't be calculated for non-numeric vectors. Crucially, haven_labelled
        # vectors should be treated as non-numeric data too (they're really factors that
        # haven't been converted into factors.)
        return(NA_character_)
    }

    y <- summary(x)

    sprintf("%.1f %.1f (%.1f) %.1f %.1f", y[1], y[2], y[3], y[5], y[6])
}


# Faster than range()
min_max <- function(x) {
    x <- x[!is.na(x)]

    ifelse(is.numeric(col) && !has_class(col, "haven_labelled"),
           paste(min(col), max(col), collapse = " - "),
           NA_character_)
}

min_max2 <- function(x) {
    x <- x[!is.na(x)]

    if (is.numeric(col) && !has_class(col, "haven_labelled")) {
        return(sprintf("%s - %s", min(col), max(col)))
    } else {
        return(NA_character_)
    }
}


mark(
    class = sapply(df, class),
    typeof = sapply(df, typeof),
    unique = sapply(df, function(col) { length(unique(col)) }),
    misstrunc = sapply(df, function(col) { trunc((sum(is.na(col)) / length(col)) / 100) }),
    missround = sapply(df, function(col) { round((sum(is.na(col)) / length(col)) / 100, 1) }),
    range = sapply(df, function(col) { ifelse(is.numeric(col) && !has_class(col, "haven_labelled"), paste0(round_to(range(col)), collapse = " - "), NA_character_) }),
    min_max = sapply(df, min_max),
    min_max2 = sapply(df, min_max2),
    summ_iqr = sapply(df, summ_iqr),
    tuk = sapply(df, tuk),
    summ = sapply(df, summ),
    sep = sapply(df, sep),
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(min) %>% select(1:9)

# # A tibble: 11 × 9
#    expression      min   median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#    <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
#  1 class        33.2µs     40µs  18851.      5.62KB    12.0   9409     6      499ms
#  2 typeof       48.2µs   57.6µs  13595.      5.62KB    16.0   6789     8      499ms
#  3 min_max      25.2ms   27.7ms     35.6    26.26KB     0       18     0      506ms
#  4 missround    33.7ms   39.7ms     24.7    76.12MB     0       13     0      526ms
#  5 misstrunc    42.9ms   45.4ms     17.9    76.14MB     1.99     9     1      503ms
#  6 range          65ms   66.6ms     12.6     87.2MB     1.80     7     1      557ms
#  7 unique      217.5ms  229.2ms      4.39  295.69MB     0        3     0      683ms
#  8 summ_iqr    258.5ms  265.2ms      3.77     197MB     0        2     0      530ms
#  9 tuk         276.2ms  277.9ms      3.60  197.04MB     0        2     0      556ms
# 10 sep         281.4ms  340.4ms      2.94  352.72MB     1.47     2     1      681ms
# 11 summ          352ms  424.6ms      2.35  352.71MB     1.18     2     1      849ms





