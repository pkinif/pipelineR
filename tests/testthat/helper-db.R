# Skip DB-dependent tests when env vars are not configured
skip_if_no_db <- function() {
  required <- c("PG_DB", "PG_HOST", "PG_USER", "PG_PASSWORD", "PG_SCHEMA")
  missing <- required[!nzchar(Sys.getenv(required, ""))]
  if (length(missing) > 0) {
    testthat::skip(paste("DB not configured (missing:", paste(missing, collapse = ", "), ")"))
  }
}
