# unreleased

- CHANGED
    - `some_uniques()` has short-circuit routes for datatypes that don't need the full "random sampling to get a list of its unique values" treatment. So far this is: Factors, Logicals, and Numerics.
    - Changed "peek" separator to vertical bar `|` from comma `,` because some data may use commas within string values.
    - `save_dictionary()` generates factor files for each unique factor in the dataframe now, according to the `tsv2label` spec.
    - Sample  data (`mtcars_lab`) now has a list column added.
    
    

# sift 0.2.0 (2023-03-27)

- ADDED
    - `save_dictionary()` allows you to save a data dictionary in a form that my other package, [`tsv2label`](https://github.com/DesiQuintans/tsv2label), will accept. Closes #11.
    - `options_sift()` prints the status of all options when invoked with no arguments. Closes #12.

- FIXED
    - sift() returns a dataframe of all results, not just the first `n = sift_limit` results.



# sift 0.1.0 (2023-03-18)

- Initial commit.
