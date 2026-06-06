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
  year <- as.character(year)
  if (!year %in% c('2000', '2010', '2020')) {
    cli::cli_abort(
      '{.arg year} must be one of 2000, 2010, or 2020, not {.val {year}}.',
      call = NULL
    )
  }
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
  year <- as.character(year)
  if (!year %in% c('2000', '2010', '2020')) {
    cli::cli_abort(
      '{.arg year} must be one of 2000, 2010, or 2020, not {.val {year}}.',
      call = NULL
    )
  }
  abb <- match_state(state)
  STATE <- toupper(abb)

  cache_dir <- file.path(maup_download_path(), STATE, year)
  file_prefix <- paste0('plans_', abb, '_')
  file_suffix <- paste0('_', year, '.rds')

  # Identify which county cache files already exist
  cached <- if (dir.exists(cache_dir)) {
    existing <- list.files(
      cache_dir,
      pattern = paste0(
        '^',
        file_prefix,
        '[0-9]{3}',
        file_suffix,
        '$'
      )
    )
    sub(file_suffix, '', sub(file_prefix, '', existing))
  } else {
    character(0)
  }

  county <- if (!is.null(county)) as.character(county) else NULL

  needs_download <- isTRUE(refresh) ||
    (is.null(county) && length(cached) == 0L) ||
    (!is.null(county) && !all(county %in% cached))

  if (needs_download) {
    zip_fname <- paste0(STATE, '/', year, '/plans_', abb, '_', year, '.zip')
    dv_ensure_file_list(refresh = refresh)
    cli::cli_inform('Downloading plans for {STATE} ({year})...')
    raw <- dv_download_handle(zip_fname, 'Plans', STATE)

    tmp_zip <- tempfile(fileext = '.zip')
    on.exit(unlink(tmp_zip), add = TRUE)
    writeBin(raw, tmp_zip)

    dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    utils::unzip(tmp_zip, exdir = cache_dir, junkpaths = TRUE)

    cached <- sub(
      file_suffix,
      '',
      sub(
        file_prefix,
        '',
        list.files(
          cache_dir,
          pattern = paste0('^', file_prefix, '[0-9]{3}', file_suffix, '$')
        )
      )
    )
  }

  if (length(cached) == 0L) {
    cli::cli_abort('No plans found for {.val {STATE}} ({year}).', call = NULL)
  }

  fips_ids <- if (!is.null(county)) {
    keep <- county %in% cached
    if (!any(keep)) {
      cli::cli_abort(
        'No plans found for the requested {.arg county} in {.val {STATE}} ({year}).',
        call = NULL
      )
    }
    county[keep]
  } else {
    cached
  }

  out <- vector('list', length(fips_ids))
  names(out) <- fips_ids
  for (i in seq_along(fips_ids)) {
    result <- readRDS(file.path(cache_dir, paste0(file_prefix, fips_ids[[i]], file_suffix)))
    out[[i]] <- unwrap_plans(result)
  }

  out
}
