test_that('match_state validates and lowercases state input', {
  expect_equal(match_state('New Jersey'), 'nj')
  expect_equal(match_state('NJ'), 'nj')
})

test_that('match_state errors on invalid state', {
  expect_snapshot(match_state('ZZ'), error = TRUE)
})

test_that('maup_download_path returns tempdir by default', {
  withr::with_options(
    list(maup.cache_dir = NULL, maup.use_cache = FALSE),
    expect_equal(maup_cache_path(), tempdir())
  )
})

test_that('maup_download_path respects maup.cache_dir option', {
  tmp <- tempfile()
  withr::with_options(
    list(maup.cache_dir = tmp),
    expect_equal(maup_cache_path(), tmp)
  )
})
