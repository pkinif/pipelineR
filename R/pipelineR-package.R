#' pipelineR: Financial data ETL pipelines with PostgreSQL
#'
#' @description
#' Fetch historical OHLCV data from Yahoo Finance for symbols listed in your
#' database, reshape it to a long format, insert only new rows into
#' `PG_SCHEMA.data_sp500`, and append batch logs to `PG_SCHEMA.pipeline_logs`.
#' The primary entry point is [`start_pipeline()`].
#'
#' @section Configuration:
#' Define these environment variables (e.g. in `.Renviron`):
#' \describe{
#'   \item{`PG_DB`, `PG_HOST`, `PG_USER`, `PG_PASSWORD`}{PostgreSQL connection.}
#'   \item{`PG_SCHEMA`}{Schema containing `data_sp500` and `pipeline_logs`.}
#'   \item{`user_login`}{Identifier written to `pipeline_logs` (required by [`push_summary_table()`]).}
#' }
#' [`connect_db()`] validates that the `PG_*` variables are set before connecting.
#'
#' @section Database layout:
#' * **`sp500.info`** (read): columns `symbol`, `index_ts` — universe of tickers to process.
#' * **`{PG_SCHEMA}.data_sp500`**: long-format prices (`index_ts`, `date`, `metric`, `value`).
#' * **`{PG_SCHEMA}.pipeline_logs`**: batch run metadata from the pipeline.
#'
#' @seealso
#' * Run the full workflow: [`start_pipeline()`]
#' * Vignette (if installed with vignettes): \code{vignette("getting-started", package = "pipelineR")}
#' * \url{https://github.com/pkinif/pipelineR}
#'
#' @aliases pipelineR-package
"_PACKAGE"
