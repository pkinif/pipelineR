test_that("connect_db returns a valid DBI connection", {
  skip_if_no_db()
  con <- connect_db()
  expect_s4_class(con, "PqConnection")
  DBI::dbDisconnect(con)
})

test_that("connect_db fails with clear message when env vars are missing", {
  old <- Sys.getenv(c("PG_DB", "PG_HOST", "PG_USER", "PG_PASSWORD", "PG_SCHEMA"), unset = NA)
  on.exit({
    for (n in names(old)) if (!is.na(old[n])) do.call(Sys.setenv, stats::setNames(list(old[n]), n))
  })
  Sys.unsetenv(c("PG_DB", "PG_HOST", "PG_USER", "PG_PASSWORD", "PG_SCHEMA"))

  expect_error(connect_db(), "Missing required env vars")
})
