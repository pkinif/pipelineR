#' Check and filter out existing data already present in the database
#'
#' This function removes rows from a new dataset if they already exist in the target PostgreSQL table.
#' It avoids inserting duplicate entries based on a unique key (symbol + date or index_ts + date).
#'
#' @param con A valid DBI database connection.
#' @param schema The schema name (e.g., \"student_paul\").
#' @param new_data A tibble containing the new data to check, must include `index_ts` and `date` columns.
#'
#' @return A tible containing only the new rows not already present in the database.
#' @export
check_existing_data <- function(con, schema = Sys.getenv("PG_SCHEMA"), new_data) {

  if (missing(con) || missing(new_data)) {
    stop("Both 'con' and 'new_data' must be provided.")
  }

  if (!all(c("index_ts", "date") %in% colnames(new_data))) {
    stop("The new_data tibble must contain 'index_ts' and 'date' columns.")
  }

  # Get distinct existing index_ts and dates from the database
  existing <- DBI::dbGetQuery(con, glue::glue_sql(
    "SELECT index_ts, date FROM {`schema`}.data_sp500",
    .con = con
  )) |>
    tibble::as_tibble()

  if (nrow(existing) == 0) {
    message("No existing data found in database, inserting all new data.")
    return(new_data)
  }

  # Anti-join: keep only rows not present already
  filtered <- new_data |>
    dplyr::anti_join(existing, by = c("index_ts", "date"))

  return(filtered)
}
