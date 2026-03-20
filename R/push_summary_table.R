#' Write batch logs to `pipeline_logs`
#'
#' Appends `summary_table` to `{PG_SCHEMA}.pipeline_logs` with [DBI::dbWriteTable()].
#' Adds column `user_login` from `user_login` or `Sys.getenv("user_login")`;
#' that environment variable must be set for the default to work.
#'
#' @param con DBI connection.
#' @param summary_table Tibble from [build_summary_table()] and [log_summary()].
#' @param user_login Student or job id; default reads `Sys.getenv("user_login")`.
#'
#' @return `invisible(NULL)`. If `summary_table` has zero rows, only a message is printed.
#' @export
#' @seealso [log_summary()], [start_pipeline()]
push_summary_table <- function(con, summary_table, user_login = Sys.getenv('user_login')) {

  if (is.null(con) || is.null(summary_table) || is.null(user_login) || user_login == "") {
    stop("Parameters 'con', 'summary_table', and 'user_login' must be provided.")
  }

  if (nrow(summary_table) == 0) {
    message("No logs to insert.")
    return(invisible(NULL))
  }

  # Add user_login column
  summary_table <- summary_table |>
    dplyr::mutate(user_login = user_login) |>
    dplyr::select(user_login, batch_id, symbol, status, n_rows, message, timestamp)

  schema <- Sys.getenv("PG_SCHEMA")

  DBI::dbWriteTable(
    conn = con,
    name = DBI::Id(schema = schema, table = "pipeline_logs"),
    value = summary_table,
    append = TRUE,
    row.names = FALSE
  )

  message("Summary table pushed to database")

  invisible(NULL)
}
