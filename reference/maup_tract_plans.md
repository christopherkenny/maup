# Download MAUP county-level plans

Downloads tract-level redistricting simulation plans from the MAUP
Project's Harvard Dataverse. Each county's plans are downloaded
separately and returned as a named list.

## Usage

``` r
maup_tract_plans(state, county = NULL, year = 2020, refresh = FALSE)
```

## Arguments

- state:

  A state name, abbreviation, or FIPS code.

- county:

  An optional character vector of 3-digit county FIPS codes. If `NULL`
  (the default), all counties for the state are downloaded.

- year:

  The redistricting cycle year.

- refresh:

  If `TRUE`, ignore the cache and download again.

## Value

A named list of
[redist_plans](http://alarm-redist.org/redist/reference/redist_plans.md)
objects, named by county FIPS code.

## Examples

``` r
if (FALSE) { # Sys.getenv("DATAVERSE_KEY") != ""
maup_tract_plans('NJ', year = 2020)
maup_tract_plans('NJ', year = 2020, county = '001')
}
```
