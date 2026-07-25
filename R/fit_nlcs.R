#' Construct a normative latent cognitive structure
#'
#' Automatically evaluates whether the HC data support a one-factor solution
#' using parallel analysis and the MAP procedure. An N-LCS is constructed only when both methods recommend one factor.
#' @param hc_z Healthy-control cognitive tests already standardized with
#'   [standardize_normative()].
#' @param parallel_iter Number of parallel-analysis iterations.
#' @param loading_tolerance Absolute loading below which a loading is treated as
#'   zero when classifying CDM as directional or magnitude-based.
#' @return An `nlcs_result` object.
#' @export
fit_nlcs <- function(hc_z, parallel_iter = 1000L, loading_tolerance = 1e-8) {
  x <- .as_numeric_matrix(hc_z, "hc_z")
  if (ncol(x) < 2L) stop("At least two cognitive tests are required.", call. = FALSE)
  if (parallel_iter < 1L) stop("`parallel_iter` must be at least 1.", call. = FALSE)

  pa <- psych::fa.parallel(x, fa = "fa", n.iter = parallel_iter, plot = FALSE, print = FALSE)
  map <- EFAtools::N_FACTORS(x, criteria = "MAP")
  pa_factors <- as.integer(pa$nfact)
  map_factors <- as.integer(map$n_factors[["MAP_TR2"]])
 message(
  "Parallel analysis suggests number of factors = ",
  pa_factors
)

message(
  "MAP suggests number of factors = ",
  map_factors
)
  if (is.na(pa_factors) || is.na(map_factors)) {
    stop("Factor-retention analysis did not return a usable PA and MAP result.", call. = FALSE)
  }
  if (pa_factors != 1L || map_factors != 1L) {
    stop(
      sprintf("N-LCS requires a one-factor solution; parallel analysis recommended %d factor(s) and original MAP recommended %d.", pa_factors, map_factors),
      call. = FALSE
    )
  }

  fa_fit <- psych::fa(x, nfactors = 1L, rotate = "none", fm = "minres")
  loading <- drop(as.matrix(fa_fit$loadings)[, 1L])
  names(loading) <- colnames(x)
  sigma <- stats::cov(x)
  eig <- eigen(sigma, symmetric = TRUE)
  if (any(eig$values <= sqrt(.Machine$double.eps))) {
    stop("The HC covariance matrix is not positive definite; whitening cannot be computed.", call. = FALSE)
  }
  whitening_matrix <- eig$vectors %*% diag(1 / sqrt(eig$values)) %*% t(eig$vectors)
  latent_axis_whitened <- drop(whitening_matrix %*% loading)
  latent_axis_whitened <- latent_axis_whitened / sqrt(sum(latent_axis_whitened ^ 2))
  names(latent_axis_whitened) <- colnames(x)

  nonzero_loading <- loading[abs(loading) > loading_tolerance]
  if (!length(nonzero_loading)) stop("All factor loadings are effectively zero.", call. = FALSE)
  same_direction <- length(unique(sign(nonzero_loading))) == 1L
  cdm_type <- if (same_direction) "axis_projection" else "whitened_magnitude"

  nlcs_result <- list(
    variables = colnames(x), hc_z_mean = colMeans(x), covariance = sigma,
    whitening_matrix = whitening_matrix, fa = fa_fit, loadings = loading,
    latent_axis_whitened = latent_axis_whitened, parallel_analysis = pa,
    map = map, retention = list(parallel_analysis = pa_factors, map_tr2 = map_factors),
    loading_tolerance = loading_tolerance, cdm_type = cdm_type
  )
  class(nlcs_result) <- "nlcs_result"
  raw_hc <- .raw_nlcs_metrics(x, nlcs_result)
  nlcs_result$cda_reference_median <- stats::median(raw_hc$cda_raw, na.rm = TRUE)
  nlcs_result
}

#' @export
print.nlcs_result <- function(x, ...) {
  cat("Normative latent cognitive structure (N-LCS)\n")
  cat("  Tests:", length(x$variables), "\n")
  cat("  Retention: PA =", x$retention$parallel_analysis,
      ", original MAP =", x$retention$map_tr2, "\n")
  cat("  CDM definition:", x$cdm_type, "\n")
  invisible(x)
}
