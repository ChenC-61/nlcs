#' Construct a normative latent cognitive structure
#'
#' Fits a one-factor normative latent cognitive structure (N-LCS) when
#' both parallel analysis and the original MAP procedure recommend
#' one factor.
#'
#' @param hc_z A complete, finite numeric matrix or data frame of
#'   healthy-control scores standardized using [standardize_normative()].
#'   Rows are subjects and columns are named cognitive tests.
#' @param parallel_iter Number of parallel-analysis iterations.
#' @param loading_tolerance Absolute loading threshold below which
#'   loadings are treated as zero when selecting the CDM definition.
#'
#' @return A named list of class `nlcs_result` containing:
#' \describe{
#'   \item{variables}{A character vector of test names in model order.}
#'   \item{hc_z_mean}{A named numeric vector of HC means in standardized units.}
#'   \item{covariance}{The numeric HC sample covariance matrix.}
#'   \item{whitening_matrix}{The numeric symmetric inverse square root
#'     of the HC covariance matrix. This transforms centered scores
#'     into HC covariance-standardized coordinates.}
#'   \item{fa}{The one-factor fit returned by `psych::fa()`,
#'     with classes `psych` and `fa`.}
#'   \item{loadings}{A named numeric vector of one-factor loadings.}
#'   \item{latent_axis_whitened}{A named numeric unit vector defining
#'     the fitted latent axis in whitened space. Its orientation
#'     follows the fitted loadings.}
#'   \item{parallel_analysis}{The full parallel-analysis result from
#'     `psych::fa.parallel()`, with classes `psych` and `parallel`.}
#'   \item{map}{The full MAP result from `EFAtools::N_FACTORS()`,
#'     with classes `efa_retain` and `N_FACTORS`.}
#'   \item{retention}{A list containing integer factor counts
#'     `parallel_analysis` and `map_tr2`. Both equal one in a
#'     successfully returned model.}
#'   \item{loading_tolerance}{The numeric loading threshold used
#'     to classify loading signs.}
#'   \item{cdm_type}{A character string: `"axis_projection"` when
#'     all nonzero loadings have the same sign, or
#'     `"whitened_magnitude"` when they have mixed signs.}
#'   \item{cda_reference_median}{The numeric median raw HC cognitive
#'     deviation angle in degrees, excluding undefined angles.
#'     This is subtracted when computing adjusted CDA.}
#' }
#' The model defines the HC reference geometry used by
#' [compute_nlcs_metrics()]. An error is raised if either retention
#' procedure does not recommend one factor.
#'
#' @details Parallel analysis uses random simulations. Use `set.seed()`
#'   for reproducibility. Factor-retention recommendations are
#'   reported as messages.
#'
#' @importFrom utils capture.output
#' @export
#' @examples
#' set.seed(42)
#' ability <- rnorm(100)
#' hc <- sapply(seq_len(4), function(j) {
#'   ability + rnorm(100, sd = 0.4)
#' })
#' colnames(hc) <- paste0("test", seq_len(4))
#' std <- standardize_normative(hc)
#' # Few iterations keep the example fast; use the default for analysis.
#' model <- fit_nlcs(std$hc_z, parallel_iter = 10L)
#' model$loadings
#' model$retention
fit_nlcs <- function(hc_z, parallel_iter = 1000L, loading_tolerance = 1e-8) {
  x <- .as_numeric_matrix(hc_z, "hc_z")
  if (ncol(x) < 2L) stop("At least two cognitive tests are required.", call. = FALSE)
  if (parallel_iter < 1L) stop("`parallel_iter` must be at least 1.", call. = FALSE)

  invisible(
  capture.output(
    pa <- psych::fa.parallel(
      x,
      fa = "fa",
      n.iter = parallel_iter,
      plot = FALSE
    )
  )
)
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
