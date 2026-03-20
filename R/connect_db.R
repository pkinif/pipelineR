#' Connect to PostgreSQL
#'
#' Opens a connection with [RPostgres::Postgres()] using credentials from the
#' environment. All of `PG_DB`, `PG_HOST`, `PG_USER`, `PG_PASSWORD`, and
#' `PG_SCHEMA` must be set and non-empty; otherwise an error is raised before
#' connecting. Port is fixed at `5432`.
#'
#' @section Environment variables:
#' \describe{
#'   \item{PG_DB}{Database name.}
#'   \item{PG_HOST}{Host name or IP.}
#'   \item{PG_USER}{User name.}
#'   \item{PG_PASSWORD}{Password.}
#'   \item{PG_SCHEMA}{Schema used by [insert_new_data()] and [push_summary_table()].}
#' }
#'
#' @return A DBI connection object (S4 class `"PqConnection"`).
#' @export
#' @seealso [start_pipeline()], [fetch_symbols()], [DBI::dbDisconnect()]
#'
#' @examples
#' \dontrun{
#' con <- connect_db()
#' DBI::dbListTables(con)
#' DBI::dbDisconnect(con)
#' }
connect_db <- function() {
  required <- c("PG_DB", "PG_HOST", "PG_USER", "PG_PASSWORD", "PG_SCHEMA")
  missing <- required[!nzchar(Sys.getenv(required, ""))]
  if (length(missing) > 0) {
    stop("Missing required env vars: ", paste(missing, collapse = ", "))
  }

  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = Sys.getenv("PG_DB"),
    host = Sys.getenv("PG_HOST"),
    user = Sys.getenv("PG_USER"),
    password = Sys.getenv("PG_PASSWORD"),
    port = 5432
  )
  return(con)
}

