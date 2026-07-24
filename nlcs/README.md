# nlcs  
  
==nlcs== implements the initial N-LCS workflow from preprocessed cognitive test   
data to caculate CDM and CDA metrics.  
  
## Scope of version 0.1.0  
  
The package includes:  
  
1. HC-reference standardization;  
2. one-factor assessment using factor parallel analysis and original Velicer   
3. MAP;  
4. factor analysis and construction of the HC whitened covariance space;  
5. CDM and CDA calculation.  
  
It intentionally does not select cognitive tests, handle missing data, assess   
skewness, or impute values. Supply complete, numeric cognitive-test matrices   
whose columns are the selected tests.  
  
## Core rule  
  
==fit_nlcs()== constructs a model only if **both** parallel analysis and the   
original MAP criterion recommend one factor. It then examines the signs of the   
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

# hc and patient are complete numeric data frames or matrices.
# Their columns are the same selected cognitive tests, with the same names.
standardized <- standardize_normative(hc, patient)

# Stops with an informative message unless PA and original MAP both support one factor.
model <- fit_nlcs(standardized$hc_z)

hc_metrics <- compute_nlcs_metrics(model, standardized$hc_z, ids = hc_id)
patient_metrics <- compute_nlcs_metrics(model, standardized$new_z, ids = patient_id)

```
  
## How to cite  
  
If you use ==nlcs==, please cite the published N-LCS 1.0 paper—the paper that   
first introduced N-LCS and evaluated its clinical relevance.  
  
Chen, C. (2026). Beyond severity: Characterizing cognitive heterogeneity in schizophrenia at the level of cognitive structure. Applied Neuropsychology: Adult, 1–8. https://doi.org/10.1080/23279095.2026.2691088  
  
For reproducible work, users may additionally cite the specific ==nlcs== GitHub   
This package is licensed under the GNU General Public License, version 3 or later (GPL-3.0-or-later). 
