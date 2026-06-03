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
