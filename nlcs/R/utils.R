.as_numeric_matrix <- function(data, arg) {
  if (!is.data.frame(data) && !is.matrix(data)) {
    stop(sprintf("`%s` must be a numeric data frame or matrix.", arg), call. = FALSE)
  }
  x <- as.matrix(data)
  if (!is.numeric(x) || is.null(colnames(x))) {
    stop(sprintf("`%s` must contain numeric columns with names.", arg), call. = FALSE)
  }
  if (anyNA(x) || any(!is.finite(x))) {
    stop(sprintf("`%s` must be complete and finite; handle missing values before N-LCS analysis.", arg), call. = FALSE)
  }
  x
}

.check_matching_variables <- function(x, variables, arg) {
  if (!setequal(colnames(x), variables)) {
    stop(sprintf("`%s` must have exactly the same cognitive-test variables as the HC reference.", arg), call. = FALSE)
  }
  x[, variables, drop = FALSE]
}

.raw_nlcs_metrics <- function(x, model) {
  centered <- sweep(x, 2L, model$hc_z_mean, FUN = "-")
  whitened <- centered %*% model$whitening_matrix
  dot_product <- drop(whitened %*% model$latent_axis_whitened)
  magnitude <- sqrt(rowSums(whitened ^ 2))

  cdm <- if (identical(model$cdm_type, "axis_projection")) dot_product else magnitude
  cosine <- rep(NA_real_, length(magnitude))
  nonzero <- magnitude > 0
  cosine[nonzero] <- dot_product[nonzero] / magnitude[nonzero]
  cosine <- pmin(pmax(cosine, -1), 1)
  cda_raw <- acos(cosine) * 180 / pi

  list(cdm = cdm, cda_raw = cda_raw)
}
