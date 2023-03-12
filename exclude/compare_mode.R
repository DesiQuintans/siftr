#' # What is the fastest way of getting the mode?
#'
#' Ideally, this would come with the option of returning more than one mode,
#' in case the vector is multi-modal.

library(bench)

# FIFA 23 female_players.csv
# https://www.kaggle.com/datasets/stefanoleone992/fifa-23-complete-player-dataset
# Chosen because it's a pretty wide dataset (110 cols).
# Rows: 181,361. Cols: 110. Size: 92 MB
df <- readr::read_csv("exclude/female_players.csv")


# ---- Functions -------------------------------------------------------------------------

# https://stackoverflow.com/a/8189441/5578429
ken_williams1 <- function(v) {
    uniqv <- unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
}

# https://stackoverflow.com/a/8189441/5578429
ken_williams2 <- function(x) {
    ux <- unique(x)
    tab <- tabulate(match(x, ux))
    ux[tab == max(tab)]
}

# https://stackoverflow.com/a/53290748/5578429
dan_houghton <- function(x) {
    if ( length(x) <= 2 ) return(x[1])
    if ( anyNA(x) ) x = x[!is.na(x)]
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
}

# https://stackoverflow.com/a/57411939/5578429
shree <- function(x) {
    a <- table(x)
    as.numeric(names(a)[a == max(a)])
}

# https://stackoverflow.com/a/2547551/5578429
dan_mode <- function(x) {
    names(sort(-table(x)))[1]
}

# https://stackoverflow.com/a/13874750/5578429
rasmus <- function(x) {
    d <- density(x)
    d$x[which.max(d$y)]
}


# https://stackoverflow.com/a/2548416/5578429
teucer <- function(x) {
    freq <- table(x)
    as.numeric(names(freq)[which.max(freq)])
}


# What if I took a very imprecise way of *guessing* the mode? Focus on speed
# for large datasets.
desi_mode <- function(x, n = 2, reps = 10, guess_max = 100, na.rm = TRUE) {
    x <- x[!is.na(x)]

    if (guess_max <= length(x)) {
        # The vector is small enough to work with all elements in it.
        candidates <- x
        marker <- character(0)
    } else {
        # Use an approximation technique.
        candidates <- replicate(reps, sample(x, size = guess_max, replace = FALSE))
        marker <- cli::symbol["warning"]
    }

    freq <- sort(table(candidates), decreasing = TRUE)

    if (length(unique(freq)) <= 1) {
        # Only one value; everything occurs at same frequency.
        res <- sprintf("All unique %s", cli::symbol["warning"]))
    } else {
        return(freq[1:n])
    }
}



mark(
    ken_williams1 = sapply(df, ken_williams1),
    ken_williams2 = sapply(df, ken_williams2),
    dan_houghton = sapply(df, dan_houghton),
    shree = sapply(df, shree),
    dan_mode = sapply(df, dan_mode),
    teucer = sapply(df, teucer),
    desi_mode = sapply(df, desi_mode),
    min_time = 1,
    relative = TRUE,
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(min) %>% select(1:9)
