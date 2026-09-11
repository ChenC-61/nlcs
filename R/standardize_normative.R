#' Standardize cognitive tests to healthy controls
#'
#' Uses healthy-control (HC) means and sample standard deviations to
#' standardize HC and new-subject cognitive-test scores.
#'
#' @param hc_data A complete, finite numeric matrix or data frame.
#'   Rows are healthy controls and columns are cognitive tests.
#'   Column names are required, and each test must have a nonzero
#'   sample standard deviation.
#' @param new_data An optional complete, finite numeric matrix or data
#'   frame for new subjects, with the same test names as `hc_data`.
#'   Columns are reordered to match the HC reference.
#'
#' @return A named list of class `nlcs_standardization` containing:
#' \describe{
#'   \item{hc_z}{A numeric matrix of standardized HC scores, with the
#'     same dimensions and column names as `hc_data`.}
#'   \item{new_z}{A numeric matrix of standardized new-subject scores,
#'     with columns in HC order, or `NULL` if `new_data` is omitted.}
#'   \item{means}{A named numeric vector of HC test means.}
#'   \item{sds}{A named numeric vector of HC sample standard deviations.}
#'   \item{variables}{A character vector of test names in HC order.}
#' }
#' Each standardized score is the original score minus the HC mean,
#' divided by the HC sample standard deviation. Positive values are
#' above the HC mean and negative values are below it. Whether higher
#' scores indicate better performance depends on the original test coding.
#'
#' @export
#' @examples
#' hc <- cbind(
#'   test1 = c(8, 10, 12, 14, 16),
#'   test2 = c(3, 5, 4, 7, 6)
#' )
#' new <- cbind(test1 = c(9, 13), test2 = c(4, 6))
#' std <- standardize_normative(hc, new)
#' std$hc_z
#' std$new_z
#' std$means
#' std$sds
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
