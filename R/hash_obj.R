# Hash an object with fastdigest and update a list with its name and hash
#
#
# @param obj (String) The name of an R object as a string.
# @param hashlist (List) The list/vector that will hold named hashes.
#
# @return A named vector/list. The name is the variable name of the object that was
#     hashed, and the value is the hash itself
#
# @examples
# # Example data
# myiris <- iris
#
# # Initialise the empty hash list
# x <- list()
#
# # Add a hash
# x <- hash_obj("myiris", x)
# x
#
# ## $myiris
# ## [1] "0b3ea20866c7f9624af51089a7fe1b90"
#
# # Add another hash
# x <- hash_obj("mtcars", x)
# x
#
# # $myiris
# # [1] "0b3ea20866c7f9624af51089a7fe1b90"
# #
# # $mtcars
# # [1] "8cf6009c35431a30d621433ae7e63905"
#
# # The newly calculated hash overwrites/updates an existing hash in the list.
# # E.g. let's change myiris somehow.
# myiris <- head("myiris")
#
# x <- hash_obj("myiris", x)
# x
#
# # $myiris
# # [1] "6e5ee1af3da0e3141cb521323c8fd52c"
# #
# # $mtcars
# # [1] "8cf6009c35431a30d621433ae7e63905"
#
# @md
hash_obj <- function(df_name, hashlist) {
    # Early dev versions of sift hashed the entire object, but this became prohibitive
    # with even modest datasets (1 GB, ~ 300 cols and 2 million rows). But the entire
    # dataframe doesn't really need to be hashed, we can get lots of info from hashing
    # only part of it.
    #
    # Which parts do we hash? What actually counts as a dataframe changing, i.e. a
    # transformational event that justifies rebuilding the dictionary?
    #
    # 1. Change in number of columns
    # 2. Change in number of rows
    # 3. Change in data types
    #
    # Sorting by rows doesn't change the values of the vector.
    # Operations like filling NAs do change the values, but efficient ways to compare
    # whether a vector has changed *without* comparing to a saved version of itself
    # are unknown to me.

    df <- eval(as.symbol(df_name))

    fingerprint <- list(df[0,],  # Col names, order, types, levels, labels.
                        dim(df)  # Number of rows and columns.
                        )

    hashlist[df_name] <- fastdigest::fastdigest(fingerprint)

    return(hashlist)
}
