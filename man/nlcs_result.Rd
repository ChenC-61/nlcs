\name{nlcs_result}
\alias{print.nlcs_result}
\title{Print a Fitted Normative Latent Cognitive Structure}
\usage{
\method{print}{nlcs_result}(x, ...)
}
\arguments{
  \item{x}{An object of class \code{nlcs_result} returned by
  \code{\link{fit_nlcs}}.}
  \item{...}{Additional arguments, currently unused.}
}
\value{
The input \code{x}, a named list of class \code{nlcs_result},
returned invisibly and unchanged. Its components describe the fitted
healthy-control reference model and are documented in
\code{\link{fit_nlcs}}.

The function is called for the side effect of printing a concise
model summary to the console.
}
\description{
Prints the number of cognitive tests, factor-retention results,
and the cognitive deviation magnitude (CDM) definition.
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
print(model)
}
