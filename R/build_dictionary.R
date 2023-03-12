# Build a data dictionary from a dataframe
#
# This data dictionary can a) be exported by the user and used to relabel a dataframe,
# and b) contains pre-calculated values that are used by `sift()` to report on the
# dataframe's contents. Note that for use-case a), dataframe fields that are expected to
# have multiple values are stored as deparsed code, and `eval(parse(text = dict$col[rownum]))`
# can be used to actually run this code to get the vectors back.
build_dictionary <- function(df, dictlist) {
    df_name <- df
    df <- eval(as.symbol(df))

    start_time <- Sys.time()

    # Elements to be searched, in lists where each element may be >1 long.
    raw_colnum   <- 1:length(df)
    raw_varnames <- colnames(df)
    raw_var_labs <- sapply(df, attr, "label")
    raw_val_labs <- sapply(df, function(col) { names(attr(col, "labels")) })  # The names are what I want.
    raw_fct_lvls <- sapply(df, levels)

    # Extra details for the data dictionary
    dct_classes     <- sapply(df, class)
    dct_types       <- sapply(df, typeof)
    dct_pct_miss    <- sapply(df, function(col) { trunc((sum(is.na(col)) / length(col)) / 100) })
    # dct_rand_vals   <- sapply(df, some_values, n = 6)

    # Getting labels into vectors of length 1.
    varnames  <- crunch(raw_varnames)
    var_labs  <- crunch(raw_var_labs)
    val_labs  <- crunch(raw_val_labs)
    fct_lvls  <- crunch(raw_fct_lvls)
    # Those labels joined together to make searchable strings.
    haystacks <- smash(varnames, var_labs, val_labs, fct_lvls)

    dictionary <-
        data.frame(
            colnum         = raw_colnum,
            varname        = varnames,
            var_lab        = var_labs,
            val_lab        = codify(raw_val_labs),
            fct_lvl        = codify(raw_fct_lvls),
            class          = codify(dct_classes),
            type           = dct_types,
            pct_miss       = dct_pct_miss,
            # rand_val       = dct_rand_vals,
            haystack       = haystacks,
            class_str      = crunch(sapply(df, class)),
            type_str       = crunch(sapply(df, typeof)),
            row.names = NULL
        )

    dictlist[df_name] <- list(dictionary)

    end_time <- Sys.time()
    elapsed <- round(end_time - start_time, digits = 2)
    elapsed_str <- paste(elapsed, attr(elapsed, "units"))

    if (options_sift("sift_loudly")) {
        cat("\n")
        cli::cli_alert_success(msg_sift("built", 1, elapsed_str))
        cat("\n")
    }

    return(invisible(dictlist))
}
