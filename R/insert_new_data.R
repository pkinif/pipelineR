#' Insert long-format prices into `data_sp500`
#'
#' Writes to `{PG_SCHEMA}.data_sp500` via [DBI::dbWriteTable()] with `append =
#' TRUE`. First loads existing `(date, index_ts, metric)` keys for the dates and
#' index codes present in `new_data`, then [dplyr::anti_join()]s so only new
#' triples are appended.
#'
#' @param con DBI connection.
#' @param new_data Tibble with columns `index_ts`, `date`, `metric`, `value` (as from [format_data()]).
#'
#' @return Integer number of rows inserted (`0` if everything was already present).
#' @export
#' @seealso [format_data()], [connect_db()], [start_pipeline()]
insert_new_data <- function(con, new_data) {

  if (is.null(con) || is.null(new_data)) {
    stop("Both 'con' and 'new_data' must be provided.")
  }

  required_cols <- c("index_ts", "date", "metric", "value")
  if (!all(required_cols %in% colnames(new_data))) {
    stop(glue::glue(
      "new_data must contain the following columns: {paste(required_cols, collapse = ', ')}"
    ))
  }

  schema <- Sys.getenv("PG_SCHEMA")

  # Load already existing combinations
  index_ts_list <- unique(new_data$index_ts)
  date_list <- unique(new_data$date)

  existing <- DBI::dbGetQuery(con, glue::glue_sql(
    "SELECT date, index_ts, metric
     FROM {`schema`}.data_sp500
     WHERE index_ts IN ({index_ts_list*})
       AND date IN ({date_list*})",
    .con = con
  ))

  # Always create a 'prepared' version
  if (nrow(existing) > 0) {
    new_data_prepared <- dplyr::anti_join(
      new_data,
      existing,
      by = c("date", "index_ts", "metric")
    )
  } else {
    new_data_prepared <- new_data
  }

  if (nrow(new_data_prepared) == 0) {
    message("No new data to insert (all data already exists).")
    return(0)
  }

  # Insert
  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = schema, table = "data_sp500"),
    value = new_data_prepared,
    append = TRUE,
    row.names = FALSE
  )

  message(glue::glue("{nrow(new_data_prepared)} new rows inserted into {schema}.data_sp500"))

  return(nrow(new_data_prepared))
}
