# nlcs  
  
==nlcs== builds one-factor N-LCS from preprocessed cognitive scores and calculates CDM and CDA.  
  
## Scope of version 1.0  
  
The package includes:  
  
1. HC-reference standardization;  
2. one-factor assessment using parallel analysis and MAP procedure;   
3. builds one-factor N-LCS and construction of the HC whitened covariance space;  
4. calculation of cognitive deviation magnitude (CDM) and cognitive deviation angle (CDA).  
  
Data preprocessing is outside the scope of N-LCS version 1.0. The package does not select cognitive tests, handle missing data, detect or remove outliers, assess skewness, perform distributional or normality transformations, or impute missing values. Users should complete these preprocessing steps before applying the N-LCS functions.

The package therefore requires complete, finite, numeric cognitive-test data, with columns corresponding to the cognitive tests selected for the N-LCS analysis.
  
## Core rule  
  
==fit_nlcs()==  builds one-factor N-LCS only if **both** parallel analysis and the   
 MAP procedure recommend one factor. It then examines the signs of the   
one-factor loadings:  
  
- all non-zero loadings have the same sign: ==CDM== is the signed projection onto   
- the whitened N-LCS axis;  
- loadings include both signs: ==CDM== is the magnitude of the individual's   
- whitened cognition vector.  
  
==CDA== is always the angle, in degrees, between the individual's whitened   
cognition vector and the N-LCS vector. The reported value subtracts the median   
raw CDA of the HC reference sample retained in the model.  
  
## Example  
  
```
library(nlcs)

# Standardization using HC reference
std <- standardize_normative(
  hc_data = hc_scores,
  new_data = scz_scores
)

# Build N-LCS
nlcs <- fit_nlcs(
  hc_z = std$hc_z
)

# HC metrics
hc_results <- compute_nlcs_metrics(
  nlcs_result = nlcs,
  data_z = std$hc_z
)

# SCZ metrics
scz_results <- compute_nlcs_metrics(
  nlcs_result = nlcs,
  data_z = std$new_z
)

# Summary table
nlcs_summary <- data.frame(
  group = rep(c("HC", "SCZ"), each = 2),
  metric = rep(c("CDM", "CDA"), 2),
  median = c(
    median(hc_results$CDM),
    median(hc_results$CDA),
    median(scz_results$CDM),
    median(scz_results$CDA)
  ),
  Q1 = c(
    quantile(hc_results$CDM, 0.25),
    quantile(hc_results$CDA, 0.25),
    quantile(scz_results$CDM, 0.25),
    quantile(scz_results$CDA, 0.25)
  ),
  Q3 = c(
    quantile(hc_results$CDM, 0.75),
    quantile(hc_results$CDA, 0.75),
    quantile(scz_results$CDM, 0.75),
    quantile(scz_results$CDA, 0.75)
  )
)

nlcs_summary


```
  
## How to cite  
  
If you use ==nlcs==, please cite the published N-LCS paper—the paper that   
first introduced N-LCS and evaluated its clinical relevance.  
  
Chen, C. (2026). Beyond severity: Characterizing cognitive heterogeneity in schizophrenia at the level of cognitive structure. Applied Neuropsychology: Adult, 1–8. https://doi.org/10.1080/23279095.2026.2691088  
  
For reproducible work, users may additionally cite the specific ==nlcs== GitHub   
This package is licensed under the GNU General Public License, version 3 or later (GPL-3.0-or-later). 
