# Create a package-local environment
# <https://stackoverflow.com/a/55622386/5578429>
.siftr_env <- NULL


.onLoad <- function(libname, pkgname) {
    # Sets up a hidden environment wherein dictionaries, hashes, etc. are stored.
    # Make the parent emptyenv() so that it does not pick up other values by
    # inheritance.
    # <https://stackoverflow.com/questions/12598242/global-variables-in-packages-in-r/12605694#comment66987725_12605694>
    .siftr_env <<- new.env(parent = emptyenv())

    # `saved_hash` is a named list of hashed dataframe fingerprints, where the
    # names are the object names of the dataframes.
    assign(x = "saved_hash", value = list(), envir = .siftr_env)

    # `saved_dict` is a named list of built dictionaries, where the names
    # are the object names of the dataframes.
    assign(x = "saved_dict", value = list(), envir = .siftr_env)

    # `last_sift` is the result of the last sift(), i.e. one dataframe.
    # Initialised as a dataframe with 0 rows and 0 cols.
    # If the last result had no matches, it can be a dataframe with 0 rows and >0 cols.
    assign(x = "last_sift", value = data.frame(), envir = .siftr_env)

    # `last_query` is a named list containing the name of last dataframe sifted,
    # the query that was run, what fields were searched, the number of matching
    # variables that resulted, and the total number of variables in the
    # dataframe.
    assign(x = "last_query", value = list("df" = "", "loc" = "", "query" = "", "matches" = 0, "total" = 0), envir = .siftr_env)
}


.onUnload <- function(libname, pkgname) {
    rm(.siftr_env)
}
