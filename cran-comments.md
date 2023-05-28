## R CMD check results

0 errors | 0 warnings | 4 notes

* This is a new release.

* Examples in sift() are wrapped in \dontrun because they have side-effects (print to console).

* Examples in options_sift() are wrapped in \dontrun because they alter options().

* Examples in save_dictionary() are wrapped in \dontrun because they would create a file in the filesystem.


## Response to feedback 2023-05-24

Thank you for your time and feedback! Paraphrased reviewer comments are prefixed with >, and responses are underneath and indented.

> Please rather use the Authors@R field and declare Maintainer, Authors and Contributors with their appropriate roles with person() calls.

    Fixed.
    
> please write the name of your package in your description without a capital S.

    Fixed.

> It seems like you have too many spaces in your description field. Probably because linebreaks count as spaces too. Please remove unecassary ones.

    Removed trailing spaces from ends of Description lines, hopefully that fixes it.

> In your LICENSE file you claim 'sift authors' as the copyrightholders. I suppose you mean yourself? In that case please write 'siftr authors' instead.

    Fixed.

> Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies. Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir().

    Fixed. save_dictionary() now throws an error if `path` is not manually specified by the user, and the function's Example writes to `tempdir()`. 

> \dontrun{} should only be used if the example really cannot be executed [...] Please replace \dontrun with \donttest.
> Please add small executable examples in your Rd-files to illustrate the use of the exported function but also enable automatic testing.

    Both fixed.

Thanks again!
