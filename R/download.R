dv_files_cache <- new.env(parent = emptyenv())

dv_ensure_file_list <- function(refresh = FALSE) {
  if (refresh) {
    rm(list = ls(dv_files_cache), envir = dv_files_cache)
  }
  if (!exists('files', envir = dv_files_cache, inherits = FALSE)) {
    full_files <- tryCatch(
      dataverse::dataset_files(DV_DOI_MAUP, server = DV_SERVER),
      error = function(e) {
        cli::cli_abort(
          c(
            'Could not connect to Dataverse.',
            'i' = 'Check your API key and internet connection.'
          ),
          parent = e,
          call = NULL
        )
      }
    )
    ids <- vapply(full_files, \(f) f$dataFile$id, integer(1))
    names(ids) <- vapply(full_files, \(f) f$label, character(1))
    assign('files', ids, envir = dv_files_cache)
  }
  get('files', envir = dv_files_cache)
}

dv_download_handle <- function(fname, type = 'File', state = '') {
  files <- dv_ensure_file_list()

  if (!fname %in% names(files)) {
    cli::cli_abort('{type} not found for {.val {state}}.', call = NULL)
  }

  tryCatch(
    dataverse::get_file_by_id(files[[fname]], server = DV_SERVER),
    error = function(e) {
      cli::cli_abort('Download failed for {.val {fname}}.', parent = e, call = NULL)
    }
  )
}

read_rds_xz <- function(raw) {
  con <- rawConnection(memDecompress(raw, type = 'xz'))
  on.exit(close(con))
  readRDS(con)
}
