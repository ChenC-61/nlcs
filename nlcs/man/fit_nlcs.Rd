\name{fit_nlcs}
\alias{fit_nlcs}
\title{Construct a normative latent cognitive structure}
\usage{fit_nlcs(hc_z, parallel_iter = 1000L, loading_tolerance = 1e-8)}
\arguments{
  \item{hc_z}{Healthy-control cognitive tests standardized to the HC reference.}
  \item{parallel_iter}{Number of parallel-analysis iterations.}
  \item{loading_tolerance}{Threshold for treating a loading as zero when selecting the CDM definition.}
}
\value{An object of class \code{nlcs_model}.}
\description{Runs factor parallel analysis and original Velicer MAP. A model is returned only if both recommend one factor.}
