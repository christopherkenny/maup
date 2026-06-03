#' Download MAUP county-level maps
#'
#' Downloads a named list of tract-level redistricting maps from the MAUP
#' Project's Harvard Dataverse, one [redist_map][redist::redist_map] per
#' county.
#'
#' @param state A state name, abbreviation, or FIPS code.
#' @param year The redistricting cycle year.
#' @param refresh If `TRUE`, ignore the cache and download again.
#'
#' @return A named list of [redist_map][redist::redist_map] objects, one per
#'   county.
#' @export
#'
#' @examplesIf Sys.getenv('DATAVERSE_KEY') != ''
#' maup_tract_map('NJ', year = 2020)
maup_tract_map <- function(state, year = 2020, refresh = FALSE) {
  year <- rlang::arg_match(year, c(2000L, 2010L, 2020L))
  abb <- match_state(state)
  fname <- paste0('map_', abb, '_', year, '.rds')
  path <- file.path(maup_download_path(), fname)

  if (!file.exists(path) || isTRUE(refresh)) {
    dv_ensure_file_list(refresh = refresh)
    raw <- dv_download_handle(fname, 'Map', toupper(abb))
    out <- read_rds_xz(raw)
    saveRDS(out, path)
  } else {
    out <- readRDS(path)
  }

  out
}

#' Download MAUP county-level plans
#'
#' Downloads tract-level redistricting simulation plans from the MAUP
#' Project's Harvard Dataverse. Each county's plans are downloaded separately
#' and returned as a named list.
#'
#' @param state A state name, abbreviation, or FIPS code.
#' @param year The redistricting cycle year.
#' @param refresh If `TRUE`, ignore the cache and download again.
#'
#' @return A named list of [redist_plans][redist::redist_plans] objects, named
#'   by county FIPS code.
#' @export
#'
#' @examplesIf Sys.getenv('DATAVERSE_KEY') != ''
#' maup_tract_plans('NJ', year = 2020)
maup_tract_plans <- function(state, year = 2020, refresh = FALSE) {
  year <- rlang::arg_match(year, c(2000L, 2010L, 2020L))
  abb <- match_state(state)
  cache_path <- file.path(maup_download_path(), paste0('plans_', abb, '_', year, '.rds'))

  if (!file.exists(cache_path) || isTRUE(refresh)) {
    files <- dv_ensure_file_list(refresh = refresh)
    prefix <- paste0('plans_', abb, '_')
    suffix <- paste0('_', year, '.rds')
    county_fnames <- names(files)[
      startsWith(names(files), prefix) & endsWith(names(files), suffix)
    ]

    if (length(county_fnames) == 0) {
      cli::cli_abort('No plans found for {.val {toupper(abb)}} ({year}).', call = NULL)
    }

    out <- lapply(
      cli::cli_progress_along(county_fnames, name = 'Downloading plans'),
      function(i) {
        fname <- county_fnames[[i]]
        raw <- dv_download_handle(fname, 'Plans', toupper(abb))
        read_rds_xz(raw)
      }
    )

    fips_ids <- sub(suffix, '', sub(prefix, '', county_fnames))
    names(out) <- fips_ids

    saveRDS(out, cache_path, compress = 'xz')
  } else {
    out <- readRDS(cache_path)
  }

  out
}
