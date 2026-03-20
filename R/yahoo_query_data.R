#' Download OHLCV from Yahoo Finance
#'
#' Calls [tidyquant::tq_get()] with `get = "stock.prices"` for all symbols in
#' `batch_list$symbol`. On error, optionally sleeps and retries once (`retry =
#' TRUE`), then stops. Adjusted close is renamed to `close_adjusted`; optional
#' column `index_ts` in `batch_list` is aligned to each row by `symbol`.
#'
#' @param batch_list Tibble with at least `symbol`; often from [split_batch()].
#' @param from,to Date bounds (inclusive) for history.
#' @param retry If `TRUE`, one recursive retry after a random delay; if `FALSE`, propagate failure.
#'
#' @return A tibble with columns including `symbol`, `date`, `open`, `high`,
#'   `low`, `close`, `volume`, `close_adjusted` (from adjusted), `index_ts`,
#'   `source`, or `NULL` if no rows were returned.
#' @export
#' @seealso [format_data()], [start_pipeline()]
yahoo_query_data <- function(batch_list, from, to, retry = TRUE) {

  data <- NULL

  tryCatch({
    # Fetch all tickers at once
    data <- tidyquant::tq_get(
      x = batch_list$symbol,
      get = "stock.prices",
      from = from,
      to = to
    )
  }, error = function(e) {

    message("Error during Yahoo Finance query: ", e$message)

    if (retry) {
      message("Retrying after random sleep...")
      Sys.sleep(sample(6:15, 1))
      return(yahoo_query_data(batch_list, from, to, retry = FALSE))
    } else {
      stop("Retry failed: ", e$message)
    }
  })

  # Check if data is valid
  if (is.null(data) || !is.data.frame(data) || nrow(data) == 0) {
    message("No data returned for batch: ", paste(batch_list$symbol, collapse = ", "))
    return(NULL)
  }

  # Clean and format data
  cleaned_data <- data |>
    dplyr::rename(
      symbol = symbol,
      date = date,
      open = open,
      high = high,
      low = low,
      close = close,
      volume = volume,
      close_adjusted = adjusted
    ) |>
    dplyr::mutate(
      index_ts = if ("index_ts" %in% colnames(batch_list)) {
        batch_list$index_ts[match(symbol, batch_list$symbol)]
      } else {
        symbol
      },
      source = "yahoo_finance"
    ) |>
    dplyr::arrange(symbol, date)


  return(cleaned_data)
}
