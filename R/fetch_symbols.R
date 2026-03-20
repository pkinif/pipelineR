#' Fetch symbols from `sp500.info`
#'
#' Reads distinct pairs of Yahoo ticker (`symbol`) and index identifier
#' (`index_ts`) from the `sp500.info` table. This table must exist on the same
#' database you connected to with [connect_db()].
#'
#' @param con A DBI connection (e.g. from [connect_db()]).
#'
#' @return A [tibble::tibble()] with columns `symbol` and `index_ts`. If no rows
#'   are returned, gives a warning and returns an empty tibble.
#' @export
#' @seealso [split_batch()], [start_pipeline()]
fetch_symbols <- function(con) {

  if (is.null(con)) {
    stop("Parameter 'con' must be provided.")
  }

  query <- glue::glue_sql(
    "SELECT DISTINCT symbol, index_ts FROM sp500.info",
    .con = con
  )

  result <- DBI::dbGetQuery(con, query)

  if (nrow(result) == 0) {
    warning("No symbols found in the database.")
  }

  tibble::as_tibble(result)
}
