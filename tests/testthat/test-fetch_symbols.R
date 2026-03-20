test_that("fetch_symbols() returns a tibble", {
  skip_if_no_db()
  con <- connect_db()
  symbols <- fetch_symbols(con = con)
  expect_s3_class(symbols, "tbl_df")
  DBI::dbDisconnect(con)
})

test_that("fetch_symbols() has required columns", {
  skip_if_no_db()
  con <- connect_db()
  symbols <- fetch_symbols(con)
  expect_true(all(c("symbol", "index_ts") %in% colnames(symbols)))
  DBI::dbDisconnect(con)
})

test_that("fetch_symbols() returns non-empty tibble if data exists", {
  skip_if_no_db()
  con <- connect_db()
  symbols <- fetch_symbols(con)
  expect_gt(nrow(symbols), 0)
  DBI::dbDisconnect(con)
})
