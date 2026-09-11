\name{fit_nlcs}
\alias{fit_nlcs}
\title{Construct a Normative Latent Cognitive Structure}
\usage{
fit_nlcs(hc_z, parallel_iter = 1000L, loading_tolerance = 1e-8)
}
\arguments{
  \item{hc_z}{A complete, finite numeric matrix or data frame of
  healthy-control scores standardized using
  \code{\link{standardize_normative}}. Rows are subjects and
  columns are named cognitive tests.}

  \item{parallel_iter}{Number of parallel-analysis iterations.}

  \item{loading_tolerance}{Absolute loading threshold below which
  loadings are treated as zero when selecting the cognitive
  deviation magnitude (CDM) definition.}
}
\value{
A named list of class \code{nlcs_result} containing:
\describe{
  \item{variables}{A character vector of test names in model order.}

  \item{hc_z_mean}{A named numeric vector of healthy-control
  means in standardized units.}

  \item{covariance}{The numeric healthy-control sample
  covariance matrix.}

  \item{whitening_matrix}{The numeric symmetric inverse square
  root of the healthy-control covariance matrix. This transforms
  centered scores into healthy-control covariance-standardized
  coordinates.}

  \item{fa}{The one-factor fit returned by \code{psych::fa()},
  with classes \code{psych} and \code{fa}.}

  \item{loadings}{A named numeric vector of one-factor loadings.}

  \item{latent_axis_whitened}{A named numeric unit vector defining
  the fitted latent axis in whitened space. Its orientation
  follows the fitted loadings.}

  \item{parallel_analysis}{The full parallel-analysis result from
  \code{psych::fa.parallel()}, with classes \code{psych} and
  \code{parallel}.}

  \item{map}{The full MAP result from
  \code{EFAtools::N_FACTORS()}, with classes \code{efa_retain}
  and \code{N_FACTORS}.}

  \item{retention}{A list containing integer factor counts
  \code{parallel_analysis} and \code{map_tr2}. Both equal one
  in a successfully returned model.}

  \item{loading_tolerance}{The numeric loading threshold used
  to classify loading signs.}

  \item{cdm_type}{A character string:
  \code{"axis_projection"} when all nonzero loadings have the
  same sign, or \code{"whitened_magnitude"} when they have
  mixed signs.}

  \item{cda_reference_median}{The numeric median raw
  healthy-control cognitive deviation angle in degrees,
  excluding undefined angles. This is subtracted when
  computing adjusted CDA.}
}
The model defines the healthy-control reference geometry used by
\code{\link{compute_nlcs_metrics}}. An error is raised if either
retention procedure does not recommend one factor.
}
\description{
Fits a one-factor normative latent cognitive structure (N-LCS)
when both parallel analysis and the original MAP procedure
recommend one factor.
}
\details{
Parallel analysis uses random simulations. Use \code{set.seed()}
for reproducibility. Factor-retention recommendations are
reported as messages.
}
\examples{
set.seed(42)
ability <- rnorm(100)
hc <- sapply(seq_len(4), function(j) {
  ability + rnorm(100, sd = 0.4)
})
colnames(hc) <- paste0("test", seq_len(4))
std <- standardize_normative(hc)

# Few iterations keep the example fast; use the default for analysis.
model <- fit_nlcs(std$hc_z, parallel_iter = 10L)
model$loadings
model$retention
}
