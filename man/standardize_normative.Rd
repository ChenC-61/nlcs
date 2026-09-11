\name{standardize_normative}
\alias{standardize_normative}
\title{Standardize Cognitive Tests to Healthy Controls}
\usage{
standardize_normative(hc_data, new_data = NULL)
}
\arguments{
  \item{hc_data}{A complete, finite numeric matrix or data frame.
  Rows are healthy controls and columns are cognitive tests.
  Column names are required. At least two healthy controls are
  required, and each test must have a nonzero sample standard
  deviation.}

  \item{new_data}{An optional complete, finite numeric matrix or
  data frame for new subjects, with the same test names as
  \code{hc_data}. Columns are reordered to match the
  healthy-control reference.}
}
\value{
A named list of class \code{nlcs_standardization} containing:
\describe{
  \item{hc_z}{A numeric matrix of standardized healthy-control
  scores, with the same dimensions and column names as
  \code{hc_data}.}

  \item{new_z}{A numeric matrix of standardized new-subject
  scores, with columns in healthy-control order, or \code{NULL}
  if \code{new_data} is omitted.}

  \item{means}{A named numeric vector of healthy-control
  test means.}

  \item{sds}{A named numeric vector of healthy-control
  sample standard deviations.}

  \item{variables}{A character vector of test names in
  healthy-control column order.}
}
Each standardized score is the original score minus the
healthy-control mean, divided by the healthy-control sample
standard deviation. Positive values are above the healthy-control
mean and negative values are below it. Whether higher scores
indicate better performance depends on the original test coding.
}
\description{
Uses healthy-control means and sample standard deviations as
the normative reference for both healthy controls and new subjects.
}
\details{
Data cleaning, test selection, missing-data handling, and direction
recoding must be completed before using this function.
}
\examples{
hc <- cbind(
  test1 = c(8, 10, 12, 14, 16),
  test2 = c(3, 5, 4, 7, 6)
)
new <- cbind(test1 = c(9, 13), test2 = c(4, 6))

std <- standardize_normative(hc, new)
std$hc_z
std$new_z
std$means
std$sds
}
