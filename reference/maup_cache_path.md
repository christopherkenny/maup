# Return the path to the `maup` cache

Returns the path to the directory where downloaded files are cached. Use
`options(maup.use_cache = TRUE)` to enable persistent caching, or
`options(maup.cache_dir = '/path/to/dir')` to specify a custom location.

## Usage

``` r
maup_cache_path()
```

## Value

A character string giving the cache directory path.

## Examples

``` r
maup_cache_path()
#> [1] "/tmp/Rtmpv1jYav"
```
