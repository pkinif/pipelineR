test_that("push_summary_table() inserts summary logs successfully", {
  skip_if_db_tables_missing("pipeline_logs")
  con <- connect_db()

  # Create a fake summary_table
  summary_table <- tibble::tibble(
    batch_id = 1,
    symbol = "FAKE",
    status = "ok",
    n_rows = 2,
    message = "Test log",
    timestamp = lubridate::now()
  )

  # Push the summary
  expect_invisible(push_summary_table(con = con,
                                      summary_table = summary_table))

  # Check if the data exists
  schema <- Sys.getenv("PG_SCHEMA")
  result <- DBI::dbGetQuery(con, glue::glue_sql(
    "SELECT * FROM {`schema`}.pipeline_logs WHERE symbol = 'FAKE'",
    .con = con
  ))

  expect_true(nrow(result) >= 1)

  # Clean up: delete inserted test log
  DBI::dbExecute(con, glue::glue_sql(
    "DELETE FROM {`schema`}.pipeline_logs WHERE symbol = 'FAKE'",
    .con = con
  ))

  DBI::dbDisconnect(con)
})
