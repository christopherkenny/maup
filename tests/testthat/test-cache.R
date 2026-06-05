test_that('maup_cache_path returns a string', {
  expect_type(maup_cache_path(), 'character')
})

test_that('maup_cache_size returns invisibly with a message', {
  expect_message(x <- maup_cache_size())
  expect_type(x, 'double')
})
