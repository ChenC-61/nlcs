#' Standardize cognitive tests to healthy controls
#'
#' Uses healthy-control (HC) means and sample standard deviations as the
#' normative reference for both HC and new subjects. Data cleaning, test
#' selection, missing-data handling, and direction recoding are deliberately
#' outside this function.
#'
#' @param hc_data Numeric HC cognitive-test data. Rows are subjects and columns
#'   are tests; column names are required.
#' @param new_data Optional numeric cognitive-test data for other subjects.
#'   It must contain exactly the same named columns as `hc_data`.
#' @return A list with `hc_z`, `new_z`, `means`, `sds`, and `variables`.
#' @export
standardize_normative <- function(hc_data, new_data = NULL) {
  hc <- .as_numeric_matrix(hc_data, "hc_data")
  if (nrow(hc) < 2L) {
    stop("`hc_data` must contain at least two healthy controls.", call. = FALSE)
  }
  means <- colMeans(hc)
  sds <- apply(hc, 2L, stats::sd)
  if (any(sds == 0)) {
    bad <- paste(names(sds)[sds == 0], collapse = ", ")
    stop(sprintf("HC standard deviation is zero for: %s.", bad), call. = FALSE)
  }
  hc_z <- sweep(sweep(hc, 2L, means, "-"), 2L, sds, "/")

  new_z <- NULL
  if (!is.null(new_data)) {
    new <- .as_numeric_matrix(new_data, "new_data")
    new <- .check_matching_variables(new, colnames(hc), "new_data")
    new_z <- sweep(sweep(new, 2L, means, "-"), 2L, sds, "/")
  }

  structure(
    list(hc_z = hc_z, new_z = new_z, means = means, sds = sds,
         variables = colnames(hc)),
    class = "nlcs_standardization"
  )
}
