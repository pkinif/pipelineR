#' Query Yahoo Finance for historical OHLCV stock data
#'
#' This function fetches full OHLCV (Open, High, Low, Close, Volume) data from Yahoo Finance
#' for a given batch of tickers using tidyquant::tq_get. It automatically handles optional retrying
#' in case of API errors for better stability.
#'
#' @param batch_list A tibble with at least a column `symbol`, typically output from `split_batch()`.
#' @param from A Date indicating the start date for historical data.
#' @param to A Date indicating the end date for historical data.
#' @param retry Logical. If TRUE, allows retrying once in case of failure. If FALSE, stops immediately after the first error. Default is TRUE.
#'
#' @return A tibble containing the fetched OHLCV data with columns: symbol, date, open, high, low, close, volume, adjusted, index_ts, source.
#' @export
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
