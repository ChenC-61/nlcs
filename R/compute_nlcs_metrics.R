#' Compute N-LCS CDM and CDA metrics
#'
#' Computes cognitive deviation magnitude (CDM) and cognitive
#' deviation angle (CDA) relative to a fitted HC reference model.
#'
#' @param nlcs_result An object of class `nlcs_result` returned by
#'   [fit_nlcs()].
#' @param data_z A complete, finite numeric matrix or data frame
#'   standardized using the same HC reference as the model.
#'   Rows are subjects. Columns must have the model's test names
#'   and are reordered to model order.
#' @param ids An optional vector of subject identifiers, with
#'   one identifier per row of `data_z`.
#'
#' @return A `data.frame` with one row per input subject, in input
#'   row order, containing:
#' \describe{
#'   \item{id}{Subject identifiers, included only when `ids` is supplied.}
#'   \item{CDM}{A numeric cognitive deviation measure. When `CDM_type`
#'     is `"axis_projection"`, this is the signed projection of the
#'     HC-centered, whitened score vector onto the fitted unit axis.
#'     Its sign follows the orientation of the fitted loadings.
#'     When `CDM_type` is `"whitened_magnitude"`, it is the nonnegative
#'     Euclidean length of that vector, representing distance from
#'     the HC center in HC covariance-standardized coordinates.}
#'   \item{CDA_raw}{The numeric angle in degrees, between 0 and 180,
#'     from the whitened score vector to the fitted axis. Smaller
#'     angles indicate closer directional alignment. The angle is
#'     `NA` when the whitened score vector has zero length.}
#'   \item{CDA}{Numeric `CDA_raw` minus the median raw HC angle stored
#'     in the model. Positive values indicate angles above the HC
#'     median; negative values indicate angles below it.
#'     Undefined raw angles remain `NA`.}
#'   \item{CDM_type}{A character column containing `"axis_projection"`
#'     or `"whitened_magnitude"`, as determined by the model.}
#' }
#'
#' @export
#' @examples
#' set.seed(42)
#' ability <- rnorm(100)
#' hc <- sapply(seq_len(4), function(j) {
#'   ability + rnorm(100, sd = 0.4)
#' })
#' colnames(hc) <- paste0("test", seq_len(4))
#' new <- hc[1:3, , drop = FALSE] - 0.5
#' std <- standardize_normative(hc, new)
#' # Few iterations keep the example fast; use the default for analysis.
#' model <- fit_nlcs(std$hc_z, parallel_iter = 10L)
#' scores <- compute_nlcs_metrics(
#'   model,
#'   std$new_z,
#'   ids = c("A", "B", "C")
#' )
#' scores
compute_nlcs_metrics <- function(nlcs_result, data_z, ids = NULL) {
  if (!inherits(nlcs_result, "nlcs_result")) stop("`nlcs_result` must be an `nlcs_result`.", call. = FALSE)
  x <- .as_numeric_matrix(data_z, "data_z")
  x <- .check_matching_variables(x, nlcs_result$variables, "data_z")
  if (!is.null(ids) && length(ids) != nrow(x)) {
    stop("`ids` must have one value per row of `data_z`.", call. = FALSE)
  }
  raw <- .raw_nlcs_metrics(x, nlcs_result)
  out <- data.frame(
    CDM = raw$cdm,
    CDA_raw = raw$cda_raw,
    CDA = raw$cda_raw - nlcs_result$cda_reference_median,
    CDM_type = rep(nlcs_result$cdm_type, nrow(x)),
    check.names = FALSE
  )
  if (!is.null(ids)) out <- cbind(id = ids, out)
  out
}
