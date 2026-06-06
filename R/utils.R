# if plans file is stored as list(county_fips = redist_plans), unwrap it
unwrap_plans <- function(x) {
  if (is.list(x) && length(x) == 1 && inherits(x[[1]], 'redist_plans')) {
    x[[1]]
  } else {
    x
  }
}

# validate and normalize a state input to a lowercase abbreviation
match_state <- function(state) {
  abb <- censable::match_abb(state)
  if (length(abb) != 1 || is.na(abb)) {
    cli::cli_abort(
      c(
        '{.arg state} must correspond to a single state.',
        'x' = 'Could not match {.val {state}} to a state.'
      ),
      call = NULL
    )
  }
  tolower(abb)
}
