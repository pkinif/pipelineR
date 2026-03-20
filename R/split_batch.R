#' Split symbols into batches
#'
#' Splits `symbol_list` into a list of tibbles of at most `batch_size` rows
#' each, preserving row order. Batching reduces Yahoo Finance rate limits,
#' timeouts, and partial responses when many tickers are requested at once.
#'
#' @param symbol_list A tibble with at least column `symbol` (typically from [fetch_symbols()]).
#' @param batch_size Maximum rows per batch. Default `25`.
#'
#' @return A list of tibbles; empty input yields an empty list (with a warning).
#' @export
#' @seealso [yahoo_query_data()], [start_pipeline()]
split_batch <- function(symbol_list, batch_size = 25) {

  if (!tibble::is_tibble(symbol_list)) {
    stop("'symbol_list' must be a tibble.")
  }

  n <- nrow(symbol_list)

  if (n == 0) {
    warning("Input 'symbol_list' is empty.")
    return(list())
  }

  # Create sequence of indices for batching
  batch_indices <- split(seq_len(n), ceiling(seq_len(n) / batch_size))

  # Split the tibble into batches
  batches <- lapply(batch_indices, function(idx) symbol_list[idx, , drop = FALSE])

  return(batches)
}
