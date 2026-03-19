test_that("format_data() reshapes wide OHLCV to long format", {
  ohlcv <- tibble::tibble(
    symbol = "AAPL",
    date = as.Date("2024-01-02"),
    open = 100, high = 105, low = 99, close = 103,
    volume = 1e6, adjusted = 103,
    index_ts = "AAPL", source = "yahoo"
  ) |>
    dplyr::rename(close_adjusted = adjusted)

  result <- format_data(ohlcv)

  expect_s3_class(result, "tbl_df")
  expect_equal(colnames(result), c("index_ts", "date", "metric", "value"))
  expect_equal(nrow(result), 6L)  # open, high, low, close, volume, close_adjusted
  expect_true(all(c("open", "high", "low", "close", "volume", "close_adjusted") %in% result$metric))
})

test_that("format_data() fails when ohlcv is NULL", {
  expect_error(format_data(NULL), "ohlcv")
})
