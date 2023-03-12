display_row <- function(dr) {
    # apply() sends dr as a named Character vector.

    cli::cli({
        cli::cli_text(cli::col_grey(dr["colnum"]), " ", cli::style_bold(dr["varname"]))

        cli::cli_div(class = "tmp",
                     theme = list(.tmp = list("margin-left" = 4,
                                              "margin-right" = 4)))

            if (!any(dr["var_lab"] == c("NULL", "", character(0)))) {
                cli::cli_text(cli::col_grey(dr["var_lab"]))
            }

            cli::cli_div(class = "tmp2",
                         theme = list(.tmp2 = list("margin-left" = 4,
                                                  "margin-right" = 0)))

            # This should check whether the summary stat is NA/NULL, and if it's not, then print it.
            # This means that control of what is displayed from the dictionary is held here, and
            # control over what is calculated at a variable level is rightly held
            # inside the build_dictionary() function and what it decided to compute.

            # Controls what gets printed.
            print_stat <- function(col, fmt) {
                if (!is.na(col) & col != "NULL") {
                    paste(cli::col_grey(fmt), cli::col_grey(col))
                } else {
                    paste(cli::col_grey(fmt), cli::col_grey("--"))
                }
            }

            # cli::cli_verbatim(cli::col_grey(paste(
            #     print_stat(dr["modes"], "Mode: %s"),
            #     print_stat(dr["range"], "Range: %s"),
            #     print_stat(dr["median_iqr"], "IQR: %s"),
            #     sep = "\t"
            # )))

            cli::cli_verbatim(
                cli::ansi_columns(
                    c(print_stat(dr["class_str"],  "Class:"),
                      print_stat(dr["type_str"],   "Type:"),
                      print_stat(dr["pct_miss"],   "Miss:")
                      ),
                    width = getOption("width"),
                    fill = "rows",
                    max_cols = 3,
                    align = "left",
                    sep = "    "
                )
            )

            cli::cli_text(print_stat(dr["rand_val"], "Peek:"))

            cli::cat_line()
    })
}
