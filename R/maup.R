#' Download MAUP county-level maps
#'
#' Downloads a named list of tract-level redistricting maps from the MAUP
#' Project's Harvard Dataverse, one [redist_map][redist::redist_map] per
#' county.
#'
#' @param state A state name, abbreviation, or FIPS code.
#' @param county An optional character vector of 3-digit county FIPS codes.
#'   If `NULL` (the default), all counties for the state are returned.
#' @param year The redistricting cycle year.
#' @param refresh If `TRUE`, ignore the cache and download again.
#'
#' @return A named list of [redist_map][redist::redist_map] objects, one per
#'   county.
#' @export
#'
#' @examplesIf Sys.getenv('DATAVERSE_KEY') != ''
#' maup_tract_map('NJ', year = 2020)
#' maup_tract_map('NJ', year = 2020, county = '001')
maup_tract_map <- function(state, county = NULL, year = 2020, refresh = FALSE) {
  year <- rlang::arg_match(year, c(2000L, 2010L, 2020L))
  abb <- match_state(state)
  STATE <- toupper(abb)
  fname <- paste0(STATE, '/', year, '/map_', abb, '_', year, '.rds')
  path <- file.path(maup_download_path(), STATE, year, paste0('map_', abb, '_', year, '.rds'))

  if (!file.exists(path) || isTRUE(refresh)) {
    dv_ensure_file_list(refresh = refresh)
    raw <- dv_download_handle(fname, 'Map', STATE)
    out <- read_rds_xz(raw)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    saveRDS(out, path)
  } else {
    out <- readRDS(path)
  }

  if (!is.null(county)) {
    county <- as.character(county)
    keep <- names(out) %in% county
    if (!any(keep)) {
      cli::cli_abort(
        'No map found for the requested {.arg county} in {.val {STATE}} ({year}).',
        call = NULL
      )
    }
    out <- out[keep]
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
#' @param county An optional character vector of 3-digit county FIPS codes.
#'   If `NULL` (the default), all counties for the state are downloaded.
#' @param year The redistricting cycle year.
#' @param refresh If `TRUE`, ignore the cache and download again.
#'
#' @return A named list of [redist_plans][redist::redist_plans] objects, named
#'   by county FIPS code.
#' @export
#'
#' @examplesIf Sys.getenv('DATAVERSE_KEY') != ''
#' maup_tract_plans('NJ', year = 2020)
#' maup_tract_plans('NJ', year = 2020, county = '001')
maup_tract_plans <- function(state, county = NULL, year = 2020, refresh = FALSE) {
  year <- rlang::arg_match(year, c(2000L, 2010L, 2020L))
  abb <- match_state(state)
  STATE <- toupper(abb)

  files <- dv_ensure_file_list(refresh = refresh)
  prefix <- paste0(STATE, '/', year, '/plans_', abb, '_')
  suffix <- paste0('_', year, '.rds')
  county_fnames <- names(files)[
    startsWith(names(files), prefix) & endsWith(names(files), suffix)
  ]

  if (length(county_fnames) == 0) {
    cli::cli_abort('No plans found for {.val {STATE}} ({year}).', call = NULL)
  }

  fips_ids <- sub(suffix, '', sub(prefix, '', county_fnames))

  if (!is.null(county)) {
    county <- as.character(county)
    keep <- fips_ids %in% county
    if (!any(keep)) {
      cli::cli_abort(
        'No plans found for the requested {.arg county} in {.val {STATE}} ({year}).',
        call = NULL
      )
    }
    county_fnames <- county_fnames[keep]
    fips_ids <- fips_ids[keep]
  }

  cache_dir <- file.path(maup_download_path(), STATE, year)
  cache_paths <- file.path(
    cache_dir,
    paste0('plans_', abb, '_', fips_ids, '_', year, '.rds')
  )
  needs_download <- !file.exists(cache_paths) | isTRUE(refresh)

  out <- vector('list', length(county_fnames))
  names(out) <- fips_ids

  for (i in which(!needs_download)) {
    out[[i]] <- readRDS(cache_paths[[i]])
  }

  to_dl <- which(needs_download)
  if (length(to_dl) > 0) {
    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    for (j in cli::cli_progress_along(to_dl, name = 'Downloading plans')) {
      i <- to_dl[[j]]
      raw <- dv_download_handle(county_fnames[[i]], 'Plans', STATE)
      result <- read_rds_xz(raw)
      saveRDS(result, cache_paths[[i]])
      out[[i]] <- result
    }
  }

  out
}
