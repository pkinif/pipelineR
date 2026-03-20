#' Pivot wide OHLCV to long format
#'
#' Takes the wide output of [yahoo_query_data()] and pivots `open`, `high`,
#' `low`, `close`, `volume`, and `close_adjusted` into two columns: `metric` and
#' `value`, keeping `index_ts` and `date`. The result matches the long layout
#' expected by [insert_new_data()].
#'
#' @param ohlcv Wide tibble (e.g. from [yahoo_query_data()]) with the columns above plus `index_ts`, `date`.
#'
#' @return A [tibble::tibble()] with columns `index_ts`, `date`, `metric`, `value`.
#' @export
#' @seealso [insert_new_data()], [yahoo_query_data()]
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
