library(labelled)

mtcars_lab <- mtcars

mtcars_lab <-
    data.frame(car = rownames(mtcars_lab)) |>
    cbind(mtcars_lab)

rownames(mtcars_lab) <- NULL

mtcars_lab$car <- factor(mtcars_lab$car, levels = sort(unique(mtcars_lab$car)), labels = sort(unique(mtcars_lab$car)))
mtcars_lab$am <- factor(mtcars_lab$vs, levels = c(1, 0), labels = c("Automatic", "Manual"))
mtcars_lab$cyl <- as.integer(mtcars_lab$cyl)
mtcars_lab$gear <- as.integer(mtcars_lab$gear)
mtcars_lab$carb <- as.integer(mtcars_lab$carb)
mtcars_lab$above_avg <- mtcars_lab$qsec > mean(mtcars_lab$qsec)

mtcars_lab <-
    set_value_labels(mtcars_lab,
                     vs = c(`V-shaped` = 0, Straight = 1),
                     )

# These var labels are set last because the per-column editing above would remove them if
# they had been set earlier.
mtcars_lab <-
    set_variable_labels(mtcars_lab,
                        car = "Car makes and models (1973-74 models)",
                        mpg = "Mileage (miles per gallon)",
                        cyl = "Number of cylinders the car has",
                        disp = "Displacement (cubic inches)",
                        hp = "Gross horsepower",
                        drat = "Rear axle ratio",
                        wt = "Weight (1000s of pounds)",
                        qsec = "Time to complete a 1/4 mile lap (seconds)",
                        vs = "Engine shape",
                        am = "Transmission",
                        gear = "Number of forward gears",
                        carb = "Number of carburetors",
                        above_avg = "Faster than the average 1/4 mile lap times in this dataset."
    )

dplyr::glimpse(mtcars_lab)

mtcars_lab$car
mtcars_lab$am
mtcars_lab$above_avg

usethis::use_data(mtcars_lab, overwrite = TRUE)
