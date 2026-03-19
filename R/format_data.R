
#' Format wide Yahoo Finance data into long format
#'
#' This function reshapes a wide tibble of stock prices into a long format
#' compatible with the `data_sp500` database table.
#'
#' @param ohlcv A tibble with columns like open, high, low, close, volume, close_adjusted, etc.
#'
#' @return A tibble in long format with columns: index_ts, date, metric, value.
#' @export
format_data <- function(ohlcv) {

  if (is.null(ohlcv)) {
    stop("'ohlcv' must be provided.")
  }

  # Pivot longer
  long_data <- ohlcv |>
    tidyr::pivot_longer(
      cols = c(open, high, low, close, volume, close_adjusted),
      names_to = "metric",
      values_to = "value"
    ) |>
    dplyr::select(index_ts, date, metric, value)

  return(long_data)
}
