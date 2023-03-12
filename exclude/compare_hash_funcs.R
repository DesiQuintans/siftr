# Test hashing packages for speed
library(dplyr)
library(readr)
library(digest)
library(fastdigest)
library(hashr)
library(cli)
library(bench)


# FIFA 23 female_players.csv
# https://www.kaggle.com/datasets/stefanoleone992/fifa-23-complete-player-dataset
# Chosen because it's a pretty wide dataset (110 cols).
# Rows: 181,361. Cols: 110. Size: 92 MB
testdf <- read_csv("exclude/female_players.csv")

mark(
     fastdigest = fastdigest::fastdigest(testdf),
     digest_md5 = digest::digest(testdf, algo = "md5"),
     digest_sha1 = digest::digest(testdf, algo = "sha1"),
     digest_crc32 = digest::digest(testdf, algo = "crc32"),
     digest_sha256 = digest::digest(testdf, algo = "sha256"),
     digest_sha512 = digest::digest(testdf, algo = "sha512"),
     digest_xxhash32 = digest::digest(testdf, algo = "xxhash32"),
     digest_xxhash64 = digest::digest(testdf, algo = "xxhash64"),
     digest_murmur32 = digest::digest(testdf, algo = "murmur32"),
     digest_spookyhash = digest::digest(testdf, algo = "spookyhash"),
     digest_blake3 = digest::digest(testdf, algo = "blake3"),
     hashr = hashr::hash(testdf),
     cli_animal = cli::hash_obj_animal(testdf),
     min_time = 1,
     check = FALSE,
     filter_gc = FALSE
) %>% arrange(min) %>% select(1:8)

# # A tibble: 13 × 8
#    expression          min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc
#    <bch:expr>        <dbl>  <dbl>     <dbl>     <dbl>    <dbl> <int> <dbl>
#  1 fastdigest         1      1        11.8         1       NaN     5     0
#  2 digest_spookyhash  1.87   1.71      6.46        1       NaN     3     0
#  3 digest_xxhash64    4.09   3.70      3.12    23627.      NaN     2     0
#  4 digest_murmur32    4.30   3.98      2.90    23627.      NaN     2     0
#  5 hashr              4.88   4.39      2.62    23627.      NaN     1     0
#  6 digest_md5         5.63   5.07      2.27    23627.      NaN     1     0
#  7 digest_crc32       5.77   5.20      2.21    23627.      NaN     1     0
#  8 digest_blake3      5.84   5.26      2.19    23627.      NaN     1     0
#  9 digest_sha1        6.52   5.88      1.96    23627.      NaN     1     0
# 10 digest_xxhash32    7.75   6.99      1.65    23627.      Inf     1     1
# 11 digest_sha512      8.94   8.06      1.43    23627.      NaN     1     0
# 12 digest_sha256      9.23   8.32      1.38    23627.      NaN     1     0
# 13 cli_animal        12.8   11.5       1      330764.      Inf     1     2
