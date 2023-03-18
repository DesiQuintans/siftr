# Sift

If you work as an analyst, you probably shift projects often and need to get 
oriented in a new dataset quickly. `sift` is an interactive tool that helps you 
find the column you need in a large dataframes using powerful 'fuzzy' searches. 

It was designed with medical, census, and survey data in mind, where dataframes 
can reach hundreds of columns and millions of rows. 

``` r
library(sift)
data(starwars, package = "dplyr")

# By default, sift searches for exact matches in a column's
# names, labels, levels, and unique values.
sift(starwars, color)

#> ℹ Building dictionary for 'starwars'. This only happens when it changes.
#> ✔ Dictionary was built in 0.01 secs.
#> 
#> 4 hair_color
#>         Type: character         Missing: 5 %            All same? No            
#>         Peek: auburn, grey, grey, brown, blond, white, auburn, white, …
#> 5 skin_color
#>         Type: character         Missing: 0 %            All same? No            
#>         Peek: white, blue, grey, red, green-tan, brown, fair, blue, ye…
#> 6 eye_color
#>         Type: character         Missing: 0 %            All same? No            
#>         Peek: blue-gray, yellow, unknown, red, blue, gold, black, haze…
#> 
#> ✔ There were 3 results for query `color`.


# .dist argument opts-in to approximate searching
# 0.25 = 25% of the pattern length can be substituted
sift(starwars, homewolrd, .dist = 0.25)

#> 10 homeworld
#>         Type: character         Missing: 11 %           All same? No            
#>         Peek: Serenno, Trandosha, Aleen Minor, Cerea, Cato Neimoidia, …
#> 
#> ✔ There was 1 result for query `homewolrd`.


# Regular expressions are fine too
sift(starwars, "gr(a|e)y")

#> 4 hair_color
#>         Type: character         Missing: 5 %            All same? No            
#>         Peek: auburn, grey, grey, brown, blond, white, auburn, white, …
#> 5 skin_color
#>         Type: character         Missing: 0 %            All same? No            
#>         Peek: white, blue, grey, red, green-tan, brown, fair, blue, ye…
#> 6 eye_color
#>         Type: character         Missing: 0 %            All same? No            
#>         Peek: blue-gray, yellow, unknown, red, blue, gold, black, haze…
#> 
#> ✔ There were 3 results for query `gr(a|e)y`.


# Multiple queries does an orderless look-around search
sift(mtcars_lab, gallon, mileage)

#> ℹ Building dictionary for 'mtcars_lab'. This only happens when it changes.
#> ✔ Dictionary was built in 0.01 secs.
#> 
#> 2 mpg
#>     Mileage (miles per gallon)
#>         Type: double      Missing: 0 %      All same? No                        
#>         Peek: 15.2, 21.5, 15, 30.4, 16.4, 14.3, 24.4, 15.5, 19.2, 22.8…
#> 
#> ✔ There was 1 result for query `(?=.*gallon)(?=.*mileage)`.


# Regex can be used in an orderless search too
sift(mtcars_lab, "auto(matic)*", transmission)

#> 10 am
#>     Transmission
#>         Type: factor ×2         Missing: 0 %            All same? No            
#>         Peek: Manual, and Automatic
#> 
#> ✔ There was 1 result for query `(?=.*auto(matic)*)(?=.*transmission)`.
```



## `sift` works best on labelled data

`sift` searches through these fields:

1. A column's name (`colnames(df)`)
2. Its label (`attr(col, "label")`; placed by many packages including `haven` and `labelled`)
3. Its value labels (`attr(col, "labels")`; often hold-overs from SPSS or SAS datasets)
4. Its factor levels (`levels(col)`)
5. Its unique values (`unique(col)`), sampled at random for large datasets

The more of these fields you can fill out, the more informative and powerful `sift` will be. 


# Functions in `sift`

| Function         | Description                                          |
| :--------------- | :--------------------------------------------------- |
| `sift()`         | Search through a dataframe's columns.                |
| `options_sift()` | Get and set options related to how `sift` functions. |
| `mtcars_lab`     | A dataset bundled with the package for testing.      |
