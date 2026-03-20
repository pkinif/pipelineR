# Skip DB-dependent tests when env vars are not configured
skip_if_no_db <- function() {
  required <- c("PG_DB", "PG_HOST", "PG_USER", "PG_PASSWORD", "PG_SCHEMA")
  missing <- required[!nzchar(Sys.getenv(required, ""))]
  if (length(missing) > 0) {
    testthat::skip(paste("DB not configured (missing:", paste(missing, collapse = ", "), ")"))
  }
}

# Skip when required DB tables do not exist
skip_if_db_tables_missing <- function(tables = c("data_sp500", "pipeline_logs")) {
  skip_if_no_db()
  con <- tryCatch(pipelineR::connect_db(), error = function(e) NULL)
  if (is.null(con)) {
    testthat::skip("Could not connect to DB")
  }
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  schema <- Sys.getenv("PG_SCHEMA")
  for (tbl in tables) {
    exists <- tryCatch({
      DBI::dbGetQuery(con, glue::glue_sql(
        "SELECT 1 FROM {`schema`}.{`tbl`} LIMIT 1",
        .con = con
      ))
      TRUE
    }, error = function(e) FALSE)
    if (!exists) {
      testthat::skip(paste("DB table", schema, ".", tbl, "does not exist"))
    }
  }
}
