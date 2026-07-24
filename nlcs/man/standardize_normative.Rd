\name{standardize_normative}
\alias{standardize_normative}
\title{Standardize cognitive tests to healthy controls}
\usage{standardize_normative(hc_data, new_data = NULL)}
\arguments{
  \item{hc_data}{Numeric HC cognitive-test data with named columns.}
  \item{new_data}{Optional numeric cognitive-test data for other subjects.}
}
\value{A list containing HC and new-subject z scores, HC means, HC standard deviations, and variable names.}
\description{Uses HC means and sample standard deviations as normative references. Inputs must be complete and finite.}
