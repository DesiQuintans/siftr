# unreleased

- ADDED
    - `options_sift()` gets a new option: `sift_peeklength`. This controls the approximate length of the `rand_unique` entries in the data dictionary, i.e. a list of unique values in each column. This "full peek" is used as part of the "haystack" that actually gets searched by `sift()`. It defaults to 3000 characters, but the final length increases when separators are added. Previously, a length limit of only 500 characters was hard-coded in. 3000 characters is about the length of a 1-page Word document at default settings.

- FIXED
    - `has_class()` can deal with multi-classed variables now.
    - Row names are now discarded from generated dictionaries.

- CHANGED
    - `some_uniques()` has short-circuit routes for datatypes that don't need the full "random sampling to get a list of its unique values" treatment. So far this is: Factors, Logicals, and Numerics.
    - Changed "peek" separator to vertical bar `|` from comma `,` because some data may use commas within string values.
    - `save_dictionary()` generates factor files for each unique factor in the dataframe now, according to the `tsv2label` spec.
    - Sample  data (`mtcars_lab`) now has a list column added.
    - `should_approx()` now uses `sample.int()` with the `useHash` argument, which performed better than `sample()`.
    
    

# sift 0.2.0 (2023-03-27)

- ADDED
    - `save_dictionary()` allows you to save a data dictionary in a form that my other package, [`tsv2label`](https://github.com/DesiQuintans/tsv2label), will accept. Closes #11.
    - `options_sift()` prints the status of all options when invoked with no arguments. Closes #12.

- FIXED
    - sift() returns a dataframe of all results, not just the first `n = sift_limit` results.



# sift 0.1.0 (2023-03-18)

- Initial commit.
