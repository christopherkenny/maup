# Download MAUP county-level maps

Downloads a named list of tract-level redistricting maps from the MAUP
Project's Harvard Dataverse, one
[redist_map](http://alarm-redist.org/redist/reference/redist_map.md) per
county.

## Usage

``` r
maup_tract_map(state, county = NULL, year = 2020, refresh = FALSE)
```

## Arguments

- state:

  A state name, abbreviation, or FIPS code.

- county:

  An optional character vector of 3-digit county FIPS codes. If `NULL`
  (the default), all counties for the state are returned.

- year:

  The redistricting cycle year.

- refresh:

  If `TRUE`, ignore the cache and download again.

## Value

A named list of
[redist_map](http://alarm-redist.org/redist/reference/redist_map.md)
objects, one per county.

## Examples

``` r
if (FALSE) { # Sys.getenv("DATAVERSE_KEY") != ""
maup_tract_map('NJ', year = 2020)
maup_tract_map('NJ', year = 2020, county = '001')
}
```
