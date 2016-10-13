[![Build Status](https://api.travis-ci.org/RyanLab/microclimloggers.png)](https://travis-ci.org/RyanLab/microclimloggers)

`ryanlabloggers`: Data Wrangling Functions For Microclimate Loggers

An R package to process various microclimate logger data formats used by the Ryan lab and collaborators. This package provides functions to parse and reshape microclimate logger data (e.g. iButton Hygrochron, HOBO pendant loggers) for various field projects of the [Ryan lab at UF Geography/EPI](http://www.sadieryan.net). These functions may or may not generalize to other loggers from the same manufacturers.

Installation
------------

Install `ryanlabloggers` from GitHub:

``` r
install.packages("devtools")
devtools::install_github("RyanLab/microclimloggers")
```

Examples
--------

Load `microclimloggers` package:

``` r
library("microclimloggers")
```

Get the path of an example file (HOBO RH Logger)

``` r
hobo_example_path <- system.file("extdata", "RH_41_073116.csv", package = "microclimloggers")
```

Parse the file

``` r
hobo_data <- read_hobo_csv(hobo_example_path)
```

Plot the file

``` r
plot(hobo_data)
```

![](inst/img/unnamed-chunk-5-1.png)

Meta
----

-   Please [report any issues or bugs](https://github.com/pboesu/ryanlabloggers/issues).
-   License: GPL-3
-   Get citation information for `ryanlabloggers` in R doing `citation(package = 'ryanlabloggers')`
