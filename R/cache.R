# backing store for all public cache functions
maup_download_path <- function() {
  user_cache <- getOption('maup.cache_dir')
  if (!is.null(user_cache)) {
    p <- user_cache
  } else if (getOption('maup.use_cache', FALSE)) {
    p <- tools::R_user_dir('maup', 'data')
  } else {
    p <- tempdir()
  }
  if (!dir.exists(p)) {
    dir.create(p, recursive = TRUE)
  }
  p
}

#' Report the size of the `maup` cache
#'
#' Returns the total size of all files in the cache directory.
#' Use `options(maup.use_cache = TRUE)` to enable persistent caching, or
#' `options(maup.cache_dir = '/path/to/dir')` to specify a custom location.
#' If caching is not enabled, a temporary directory is used.
#'
#' @return The total cache size in bytes, invisibly.
#' Also prints a human-readable size message.
#' @export
#'
#' @examples
#' maup_cache_size()
maup_cache_size <- function() {
  files <- list.files(maup_download_path(), recursive = TRUE, full.names = TRUE)
  x <- sum(vapply(files, file.size, numeric(1)))
  class(x) <- 'object_size'
  cli::cli_inform(format(x, unit = 'auto'))
  invisible(as.numeric(x))
}

#' Clear the `maup` cache
#'
#' Deletes all files in the cache directory.
#' If `force` is `FALSE` and the session is interactive, asks for confirmation
#' first.
#'
#' @param force If `FALSE` (the default), asks for confirmation interactively.
#'   Does not clear the cache if the session is not interactive and `force` is
#'   `FALSE`.
#'
#' @return The path to the cache directory, invisibly.
#' @export
#'
#' @examples
#' maup_cache_clear()
maup_cache_clear <- function(force = FALSE) {
  path <- maup_download_path()
  if (interactive() && !force) {
    del <- utils::askYesNo(
      msg = 'Are you sure? The entire cache will be deleted.',
      default = FALSE
    )
  } else {
    del <- force
  }
  if (isTRUE(del)) {
    unlink(path, recursive = TRUE)
  }
  invisible(path)
}

#' Return the path to the `maup` cache
#'
#' Returns the path to the directory where downloaded files are cached.
#' Use `options(maup.use_cache = TRUE)` to enable persistent caching, or
#' `options(maup.cache_dir = '/path/to/dir')` to specify a custom location.
#'
#' @return A character string giving the cache directory path.
#' @export
#'
#' @examples
#' maup_cache_path()
maup_cache_path <- function() {
  maup_download_path()
}
