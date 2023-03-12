#' # What is the fastest way of finding the dimensions of a dataframe?

# FIFA 23 female_players.csv
# https://www.kaggle.com/datasets/stefanoleone992/fifa-23-complete-player-dataset
# Chosen because it's a pretty wide dataset (110 cols).
# Rows: 181,361. Cols: 110. Size: 92 MB
testdf <- read_csv("exclude/female_players.csv")


mark(
    nrow = nrow(testdf),
    ncol = ncol(testdf),
    dim  = dim(testdf),
    length = length(testdf[[1]]),
    min_time = 1,
    relative = TRUE,
    check = FALSE,
    filter_gc = FALSE
) %>% arrange(min) %>% select(1:9)
