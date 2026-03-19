test_that("insert_new_data() inserts new rows successfully", {
  skip_if_no_db()
  con <- connect_db()

  # Create fake dataset matching table structure
  fake_data <- tibble::tibble(
    index_ts = rep("FAKE_INDEX_TS", 2),
    date = Sys.Date() + 0:1,
    metric = c("close", "volume"),
    value = c(150.25, 1000000)
  )

  # Insert new data
  n_inserted <- insert_new_data(con = con, new_data = fake_data)
  expect_equal(n_inserted, 2)

  # Re-insert same data: should insert 0 new rows
  n_inserted_again <- insert_new_data(con = con, new_data = fake_data)
  expect_equal(n_inserted_again, 0)

  # Clean up: delete inserted test data
  schema <- Sys.getenv("PG_SCHEMA")
  DBI::dbExecute(con, glue::glue_sql(
    "DELETE FROM {`schema`}.data_sp500 WHERE index_ts = 'FAKE_INDEX_TS'",
    .con = con
  ))

  DBI::dbDisconnect(con)
})

test_that("insert_new_data() fails gracefully with invalid data", {
  skip_if_no_db()
  con <- connect_db()

  # Create incomplete dataset (missing required columns)
  bad_data <- tibble::tibble(
    date = Sys.Date(),
    value = 123.45
  )

  expect_error(
    insert_new_data(con = con, new_data = bad_data),
    regexp = ".*"
  )

  DBI::dbDisconnect(con)
})
