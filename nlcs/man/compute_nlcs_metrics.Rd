\name{compute_nlcs_metrics}
\alias{compute_nlcs_metrics}
\title{Compute N-LCS CDM and CDA metrics}
\usage{compute_nlcs_metrics(model, data_z, ids = NULL)}
\arguments{
  \item{model}{An object created by \code{fit_nlcs}.}
  \item{data_z}{Cognitive tests standardized using the same HC reference.}
  \item{ids}{Optional identifiers, one for each row in \code{data_z}.}
}
\value{A data frame with CDM, raw CDA, HC-median-adjusted CDA, and CDM type.}
\description{Projects subjects into the model's whitened covariance space.}
