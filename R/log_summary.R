#' Append one batch row to the in-memory log
#'
#' Binds a new row to `summary_table` with a fresh `timestamp`. Used by
#' [start_pipeline()] after each batch (success or error). Does not write to
#' the database until [push_summary_table()].
#'
#' @param summary_table Current log tibble from [build_summary_table()] / prior calls.
#' @param batch_id Batch index (integer).
#' @param symbol Ticker string or comma-separated list for the batch.
#' @param status `"ok"` or `"error"` (convention used by the pipeline).
#' @param n_rows Number of rows inserted in that batch, or `0` on error / no new rows.
#' @param message Human-readable detail or error text.
#'
#' @return Updated tibble (new row at the bottom).
#' @export
#' @seealso [build_summary_table()], [push_summary_table()]
log_summary <- function(summary_table, batch_id, symbol, status, n_rows = 0, message = "") {

  new_row <- tibble::tibble(
    batch_id = batch_id,
    symbol = symbol,
    status = status,
    n_rows = n_rows,
    message = message,
    timestamp = lubridate::now()
  )

  dplyr::bind_rows(summary_table, new_row)
}
