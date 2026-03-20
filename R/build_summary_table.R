#' Create an empty batch log tibble
#'
#' Zero-row template used by [start_pipeline()] before [log_summary()] rows are
#' accumulated and [push_summary_table()] sends them to the database.
#'
#' @return A [tibble::tibble()] with columns `batch_id`, `symbol`, `status`,
#'   `n_rows`, `message`, `timestamp` (typed but empty).
#' @export
#' @seealso [log_summary()], [push_summary_table()]
build_summary_table <- function() {
  tibble::tibble(
    batch_id = integer(),
    symbol = character(),
    status = character(),
    n_rows = integer(),
    message = character(),
    timestamp = lubridate::now()
  )
}
