---
title: "Control Demographics"
author: "Dave Bridges and Trey Carr"
date: "April 9, 2025"
format: 
  html:
    toc: true
    toc-location: right
    keep-md: true
    code-fold: true
    code-summary: "Show the code"
    fig-path: "figures/"
  pdf: default
#theme: journal
execute:
  echo: true
  warning: false
---


::: {.cell}

```{.r .cell-code}
# hide this code chunk
#| echo: false
#| message: false

# defines the se function
se <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(length(x))
}

#load these packages, nearly always needed
library(tidyverse)

# sets maize and blue color scheme
color_scheme <- c("#00274c", "#ffcb05")
```
:::


## Purpose

To create a table about our control group demographics. SES, Race, Ethniciy, Age, and Sex specifically.

### Case Demographic Data


::: {.cell}

```{.r .cell-code}
encounter.datafile.cases <- "EncounterAll.csv" 
cushings.datafile.cases <- "CushingsDataClean.csv"
demographics.datafile.cases <- "DemographicInfo.csv"
ses.datafile.cases <- "GisNeighborhoodAffluence.csv"


library(readr) #for loading csv files
library(dplyr) #for data cleaning
library(lubridate) #for date cleaning
library(knitr) #for kables
encounter.data.cases <- read_csv(encounter.datafile.cases) |>
  mutate(DeID_AdmitDate_Clean = as_date(mdy_hm(DeID_AdmitDate))) 
demographics.data <- read_csv(demographics.datafile.cases) %>%
  mutate(DeID_DOB_clean = as_date(mdy_hm(DeID_DOB)))
ses.data <- read_csv(ses.datafile.cases)

cushings.data <- read_csv(cushings.datafile.cases) %>%
  rename("cushings_diagnosis"="DeID_AdmitDate_Clean_diagnosis",
         "cushings_procedure"="DeID_AdmitDate_Clean_procedure") %>%
  left_join(demographics.data, by="DeID_PatientID") %>%
  left_join(ses.data, by="DeID_PatientID")

case.filename <- "CaseDemographics.csv"
write_csv(cushings.data, case.filename)
```
:::


Written out cases as CaseDemographics.csv.  There was a total of 457 cases in this file.


::: {.cell}

```{.r .cell-code}
encounter.datafile.controls <- "../controls/EncounterAll.csv" 
demographics.datafile.controls  <- "../controls/DemographicInfo.csv"
ses.datafile.controls  <- "../controls/GisNeighborhoodAffluence.csv"

demographics.data <- read_csv(demographics.datafile.controls ) %>%
  mutate(DeID_DOB_clean = as_date(mdy_hm(DeID_DOB)))
ses.data <- read_csv(ses.datafile.controls )

controls.data <- demographics.data %>%
  left_join(ses.data, by="DeID_PatientID")

controls.filename <- "ControlDemographics.csv"
write_csv(controls.data, controls.filename)
```
:::


Written out cases as ControlDemographics.csv.  There was a total of 99304 cases in this file.

## Session Information


::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.4.0 (2024-04-24)
Platform: x86_64-pc-linux-gnu
Running under: Red Hat Enterprise Linux 8.8 (Ootpa)

Matrix products: default
BLAS:   /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.0/lib64/R/lib/libRblas.so 
LAPACK: /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.0/lib64/R/lib/libRlapack.so;  LAPACK version 3.12.0

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
 [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

time zone: America/Detroit
tzcode source: system (glibc)

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] knitr_1.48      lubridate_1.9.3 forcats_1.0.0   stringr_1.5.1  
 [5] dplyr_1.1.4     purrr_1.0.2     readr_2.1.5     tidyr_1.3.1    
 [9] tibble_3.2.1    ggplot2_3.5.1   tidyverse_2.0.0

loaded via a namespace (and not attached):
 [1] bit_4.0.5         gtable_0.3.5      jsonlite_1.8.8    crayon_1.5.3     
 [5] compiler_4.4.0    tidyselect_1.2.1  parallel_4.4.0    scales_1.3.0     
 [9] yaml_2.3.9        fastmap_1.2.0     R6_2.5.1          generics_0.1.3   
[13] htmlwidgets_1.6.4 munsell_0.5.1     pillar_1.9.0      tzdb_0.4.0       
[17] rlang_1.1.4       utf8_1.2.4        stringi_1.8.4     xfun_0.45        
[21] bit64_4.0.5       timechange_0.3.0  cli_3.6.3         withr_3.0.0      
[25] magrittr_2.0.3    digest_0.6.36     grid_4.4.0        vroom_1.6.5      
[29] rstudioapi_0.16.0 hms_1.1.3         lifecycle_1.0.4   vctrs_0.6.5      
[33] evaluate_0.24.0   glue_1.8.0        fansi_1.0.6       colorspace_2.1-0 
[37] rmarkdown_2.27    tools_4.4.0       pkgconfig_2.0.3   htmltools_0.5.8.1
```


:::
:::
