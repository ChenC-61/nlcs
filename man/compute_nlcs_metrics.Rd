\name{compute_nlcs_metrics}
\alias{compute_nlcs_metrics}
\title{Compute N-LCS CDM and CDA Metrics}
\usage{
compute_nlcs_metrics(nlcs_result, data_z, ids = NULL)
}
\arguments{
  \item{nlcs_result}{An object of class \code{nlcs_result}
  returned by \code{\link{fit_nlcs}}.}

  \item{data_z}{A complete, finite numeric matrix or data frame
  standardized using the same healthy-control reference as
  the model. Rows are subjects. Columns must have the model's
  test names and are reordered to model order.}

  \item{ids}{An optional vector of subject identifiers, with
  one identifier per row of \code{data_z}.}
}
\value{
A \code{data.frame} with one row per input subject, in input
row order, containing:
\describe{
  \item{id}{Subject identifiers, included only when
  \code{ids} is supplied.}

  \item{CDM}{A numeric cognitive deviation measure.
  When \code{CDM_type} is \code{"axis_projection"}, this is
  the signed projection of the healthy-control-centered,
  whitened score vector onto the fitted unit axis. Its sign
  follows the orientation of the fitted loadings.
  When \code{CDM_type} is \code{"whitened_magnitude"}, it is
  the nonnegative Euclidean length of that vector,
  representing distance from the healthy-control center in
  healthy-control covariance-standardized coordinates.}

  \item{CDA_raw}{The numeric angle in degrees, between 0 and
  180, from the whitened score vector to the fitted axis.
  Smaller angles indicate closer directional alignment.
  The angle is \code{NA} when the whitened score vector
  has zero length.}

  \item{CDA}{Numeric \code{CDA_raw} minus the median raw
  healthy-control angle stored in the model. Positive values
  indicate angles above the healthy-control median; negative
  values indicate angles below it. Undefined raw angles
  remain \code{NA}.}

  \item{CDM_type}{A character column containing
  \code{"axis_projection"} or \code{"whitened_magnitude"},
  as determined by the model.}
}
}
\description{
Computes cognitive deviation magnitude (CDM) and cognitive
deviation angle (CDA) relative to a fitted healthy-control
reference model.
}
\examples{
set.seed(42)
ability <- rnorm(100)
hc <- sapply(seq_len(4), function(j) {
  ability + rnorm(100, sd = 0.4)
})
colnames(hc) <- paste0("test", seq_len(4))

new <- hc[1:3, , drop = FALSE] - 0.5
std <- standardize_normative(hc, new)

# Few iterations keep the example fast; use the default for analysis.
model <- fit_nlcs(std$hc_z, parallel_iter = 10L)

scores <- compute_nlcs_metrics(
  model,
  std$new_z,
  ids = c("A", "B", "C")
)
scores
}
