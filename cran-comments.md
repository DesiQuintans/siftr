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
    
> In your LICENSE file you claim 'sift authors' as the copyrightholders. I suppose you mean yourself? In that case please write 'siftr authors' instead.

    Fixed.

