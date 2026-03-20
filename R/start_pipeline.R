#' Run the full ETL pipeline
#'
#' Connects to PostgreSQL, loads symbols from `sp500.info`, splits them into
#' batches, downloads OHLCV from Yahoo Finance for each batch between `from` and
#' `to`, reshapes with [format_data()], inserts only new rows with
#' [insert_new_data()], and records outcomes in memory then flushes them with
#' [push_summary_table()] to `{PG_SCHEMA}.pipeline_logs`. The connection is
#' closed on success.
#'
#' If a batch fails (API error, no rows, etc.), the error is caught, a row is
#' appended to the summary with `status = "error"`, and processing continues
#' with the next batch.
#'
#' @param from Start date (inclusive) for Yahoo Finance history. Default: seven days ago.
#' @param to End date (inclusive). Default: today.
#' @param batch_size Maximum number of symbols per batch (passed to [split_batch()]).
#'
#' @return Invisibly `NULL`. Called for side effects (database writes and messages).
#' @export
#' @seealso [connect_db()], [fetch_symbols()], [yahoo_query_data()], [insert_new_data()]
start_pipeline <- function(from = Sys.Date() - 7, to = Sys.Date(), batch_size = 25) {

  # 1. Connect to PostgreSQL
  con <- connect_db()
  message("Connection to database established.")

  # 2. Fetch symbols from database
  symbols_tbl <- fetch_symbols(con)

  if (nrow(symbols_tbl) == 0) {
    stop("No symbols found in database.")
  }

  message(glue::glue("Fetched {nrow(symbols_tbl)} symbols."))

  # 3. Initialize the summary log
  summary_table <- build_summary_table()

  # 4. Split into batches
  batches <- split_batch(symbols_tbl, batch_size = batch_size)

  message("Starting pipeline...")

  # 5. Loop over batches
  for (batch_id in seq_along(batches)) {

    batch <- batches[[batch_id]]
    symbols_in_batch <- batch$symbol

    message(glue::glue("Processing batch {batch_id}/{length(batches)}: {paste(symbols_in_batch, collapse = ', ')}"))

    tryCatch({

      # 5.1 Query Yahoo Finance
      new_data <- yahoo_query_data(batch, from = from, to = to)

      if (is.null(new_data) || nrow(new_data) == 0) {
        stop("No data returned from Yahoo Finance API.")
      }
      # 5.2 Insert into PostgreSQL
      n_inserted  <- new_data |>
        format_data() |>
        insert_new_data(con = con)

      # 5.3 Log success
      if (n_inserted > 0) {
        summary_table <- log_summary(
          summary_table = summary_table,
          batch_id = batch_id,
          symbol = paste(symbols_in_batch, collapse = ", "),
          status = "ok",
          n_rows = n_inserted,
          message = "Batch processed."
        )
      } else {
        summary_table <- log_summary(
          summary_table = summary_table,
          batch_id = batch_id,
          symbol = paste(symbols_in_batch, collapse = ", "),
          status = "ok",
          n_rows = 0,
          message = "No new rows to insert."
        )
      }

    }, error = function(e) {
      message(glue::glue("Error while processing batch {batch_id}: {e$message}"))

      # Log error
      summary_table <- log_summary(
        summary_table,
        batch_id = batch_id,
        symbol = paste(symbols_in_batch, collapse = ", "),
        status = "error",
        n_rows = 0,
        message = e$message
      )
    })

  }

  # 6. Push the summary logs into pipeline_logs table
  push_summary_table(con = con, summary_table = summary_table)

  DBI::dbDisconnect(con)

  message("Pipeline completed.")
}
