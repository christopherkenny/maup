# Report the size of the `maup` cache

Returns the total size of all files in the cache directory. Use
`options(maup.use_cache = TRUE)` to enable persistent caching, or
`options(maup.cache_dir = '/path/to/dir')` to specify a custom location.
If caching is not enabled, a temporary directory is used.

## Usage

``` r
maup_cache_size()
```

## Value

The total cache size in bytes, invisibly. Also prints a human-readable
size message.

## Examples

``` r
maup_cache_size()
#> 3.8 Mb
```
