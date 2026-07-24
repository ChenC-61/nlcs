#' Compute N-LCS CDM and CDA metrics
#'
#' Projects already HC-standardized cognitive-test scores into an N-LCS model's
#' whitened covariance space. CDA is the angle from the N-LCS vector, adjusted
#' by subtracting the HC median CDA stored when the model was fitted.
#'
#' @param model An `nlcs_model` created by [fit_nlcs()].
#' @param data_z Cognitive-test data already standardized with the HC reference.
#' @param ids Optional subject identifiers, one per row of `data_z`.
#' @return A data frame containing optional `id`, `CDM`, `CDA_raw`, `CDA`, and
#'   `CDM_type`.
#' @export
compute_nlcs_metrics <- function(model, data_z, ids = NULL) {
  if (!inherits(model, "nlcs_model")) stop("`model` must be an `nlcs_model`.", call. = FALSE)
  x <- .as_numeric_matrix(data_z, "data_z")
  x <- .check_matching_variables(x, model$variables, "data_z")
  if (!is.null(ids) && length(ids) != nrow(x)) {
    stop("`ids` must have one value per row of `data_z`.", call. = FALSE)
  }
  raw <- .raw_nlcs_metrics(x, model)
  out <- data.frame(
    CDM = raw$cdm,
    CDA_raw = raw$cda_raw,
    CDA = raw$cda_raw - model$cda_reference_median,
    CDM_type = rep(model$cdm_type, nrow(x)),
    check.names = FALSE
  )
  if (!is.null(ids)) out <- cbind(id = ids, out)
  out
}
