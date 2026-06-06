# Clear the `maup` cache

Deletes all files in the cache directory. If `force` is `FALSE` and the
session is interactive, asks for confirmation first.

## Usage

``` r
maup_cache_clear(force = FALSE)
```

## Arguments

- force:

  If `FALSE` (the default), asks for confirmation interactively. Does
  not clear the cache if the session is not interactive and `force` is
  `FALSE`.

## Value

The path to the cache directory, invisibly.

## Examples

``` r
maup_cache_clear()
```
