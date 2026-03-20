
# Packages ----------------------------------------------------------------
# install.packages("remotes")
# remotes::install_github("pkinif/pipelineR")
library(pipelineR)

# NB: don't forget to configure .Renviron

# Function ----------------------------------------------------------------
get_max_date <- function(con, schema = Sys.getenv("PG_SCHEMA")) {
  query <- glue::glue_sql(
    "SELECT max(date) FROM {`schema`}.data_sp500",
    .con = con
  )
  max_date <- DBI::dbGetQuery(con, query)
  return(max_date)
}

remove_last_days <- function(con, days = 6, schema = Sys.getenv("PG_SCHEMA")) {
  query <- glue::glue_sql(
      "DELETE FROM {`schema`}.data_sp500 WHERE date > {Sys.Date() - days}",
    .con = con
  )
  DBI::dbExecute(con, query)
}

# Code --------------------------------------------------------------------

?start_pipeline
con <- pipelineR::connect_db()
remove_last_days(con)
get_max_date(con)
start_pipeline(from = Sys.Date() - 7, to = Sys.Date(), batch_size = 100)
get_max_date(con)
DBI::dbDisconnect(con)


