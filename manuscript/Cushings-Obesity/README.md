This documemt shows where the results and tables are generated from.  Files are generated from qmd files (the source files) and the specific figure used is found in filename, generally in a folder in the same location as the source file.  All these data can be found in the folder `mgi-analysis/Cushing's Disease`

| No. | Title / Description                                                       | Source File | Filename |
|-----|---------------------------------------------------------------------------|-------------|----------|
| Figure 1  | Flow diagram of case/control identification and exclusions (CONSORT-style)|             |          |
| Figure 2 | Balance diagnostics (Love plot of matched variables)                      | propensity-mapping.qmd  | love-plots-2.pdf |
| Figure 3 | Adjusted means of outcomes by Cushing’s × Obesity groups (panel plot)     |             |          |
| Figure 4 | Forest plot of interaction (difference-in-differences across outcomes)    |             |          |
| Figure 5 (optional) | Distribution plots of raw outcomes (e.g., HbA1c)                          |             |          |
| Table 1 |  Baseline characteristics of cases vs. controls (matched sample)           | propensity-mapping.qmd | Demographic Summary - Master Sample.csv|
| Table 2 | Baseline characteristics of 2×2 groups (Lean-Control, Lean-Cushing’s, etc.)|             |          |
| Table 3 | Main adjusted results (least-squares means and interaction terms)         |             |          |
| Table 4 | Sensitivity analyses / subgroup results                                   |             |          |
| Supplementary Fig S1 | Extended distributions for all outcomes                                |             |          |
| Supplementary Fig S2 | Additional subgroup / sensitivity plots                                |             |          |
| Supplementary Tab S1 | Detailed matching diagnostics (propensity score details)                | propensity-mapping.qmd | Propensity Matching Summary - Age.csv |
| Supplementary Tab S2A | Baseline characteristics of cases vs. controls (matched sample)           | propensity-mapping.qmd | Demographic Summary - Master Sample.csv|
| Supplementary Tab SX | Extended model outputs (full regression coefficients)                   |             |          |
