---
title: "Summarizing the Diagnosis Data to Extract Diabetes Diagnoses"
author: "Dave Bridges"
date: "May 25, 2023"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: yes
    toc: yes
---

## Purpose

The Elixhauser comorbidity index uses a combination of type 1 and type 2 diabetes with and without co-morbidities to generate its data.  We want to separately identify type 2 diabetes diagnoses. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy/2023-03-14/2150 - Obesity and Stress - Cohort - DeID - 2023-03-14 and was most recently run on Mon Sep 25 13:56:09 2023.


```r
library(knitr)
#figures made will go to directory called figures, will make them as both png and pdf files 
opts_chunk$set(fig.path='figures/',
               echo=TRUE, warning=FALSE, message=FALSE,dev=c('png','pdf'))
options(scipen = 2, digits = 3)

diagnosis.datafile <- 'ClarityMedicalHistory.csv'
encounters.datafile <- 'EncounterAll.csv'
```

The encounter datafile is in EncounterAll.csv with the diagnosis data from ClarityMedicalHistory in thee file `r `diagnosis.datafile`. This latter file includes the participant, encounter, date, ICD lexicon (ICD9 or ICD10) the actual code and the name for the code.


```r
library(readr)
library(dplyr)
library(tidyr)
library(knitr)
library(lubridate)

#get diagnosis data
diagnosis.data <- read_csv(diagnosis.datafile) 
  
diagnosis.data <- 
  diagnosis.data %>%
  mutate(DeID_ProblemObservationDate=ymd_hms(DeID_ProblemObservationDate))
```

For ICD10 codes (see https://edit.cms.gov/files/document/valid-icd-10-list.xlsx), all Type 2 Diabetes codes start with *E11* and include the phrase "Type 2"

For ICD9 codes (see https://edit.cms.gov/files/document/valid-icd-9-list.xlsx), all type 2 diabetes codes contain the words type II and Diabetes though in different orders


```r
diabetes.diagnoses.icd10 <- 
  diagnosis.data %>%
  filter(grepl('E11.', DiagnosisICDCodeMapped)) #includes all ICD10 code E11

diabetes.diagnoses.icd9 <-
  diagnosis.data %>%
  filter(grepl('250.',DiagnosisICDCodeMapped)) %>% #includes ICD9 code 250.x
  filter(grepl('type II',DiagnosisICDNameMapped)) #subset of all diseases marked type II, removes type 1

#combine the two
diabetes.diagnoses <-
  bind_rows(diabetes.diagnoses.icd9,
            diabetes.diagnoses.icd10)
```

This generates a list of all diabetes related diagnoses for all participants.  We want to minimize this to generate a list of all participants who do or do not have a diabetes diagnosis (at any time).


```r
#this generates a list of all participants with at least one ID
diabetic.participants <-
  diabetes.diagnoses %>%
  distinct(DeID_PatientID)  
```

There was a total of 16221 that we identified as having type 2 diabetes

# Comparison to Elixhauser Comorbidities Index


```r
comorbidity.datafile <- 'ComorbiditiesElixhauserComprehensive.csv'
comorbidity.data <- read_csv(comorbidity.datafile)

comorbidity.diabetics <-
  comorbidity.data %>%
  filter(DiabetesUncomplicated=='1'|DiabetesComplicated=='1') %>%
  distinct(DeID_PatientID)
```

From the Elixhauser data there were 19925 people with diabetes combining those with and without complications.  This may be either type 1 or type 2.

## What percent of all elixhauser diabetic participants had type 2 diabetes?


```r
comorbidity.diabetics$DeID_PatientID %in% diabetic.participants$DeID_PatientID %>%
  table %>%
  kable(caption="Number of Elixhauser diabetics identified by IC9/10 codes, these could be type 1")
```



Table: Number of Elixhauser diabetics identified by IC9/10 codes, these could be type 1

|.     |  Freq|
|:-----|-----:|
|FALSE |  3919|
|TRUE  | 16006|

```r
diabetic.participants$DeID_PatientID %in% comorbidity.diabetics$DeID_PatientID %>%
  table %>%
  kable(caption="Number of ICD9/10 diabetics identified by Elixhauser.  These are perhaps false negatives in Elixhauser")
```



Table: Number of ICD9/10 diabetics identified by Elixhauser.  These are perhaps false negatives in Elixhauser

|.     |  Freq|
|:-----|-----:|
|FALSE |   215|
|TRUE  | 16006|

# Output


```r
combined.data <-
  comorbidity.data %>%
  mutate(Type2Diabetes = case_when(DeID_PatientID %in% diabetic.participants$DeID_PatientID ~ '1',
                                   TRUE~'0'))
  
output.file <- 'ComorbidityDataAnnotated.csv'
write_csv(combined.data, file=output.file)
```

These data were written out to ComorbidityDataAnnotated.csv. This is the input file for the other scripts.

# Session Information


```r
sessionInfo()
```

```
## R version 4.3.1 (2023-06-16)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Red Hat Enterprise Linux 8.6 (Ootpa)
## 
## Matrix products: default
## BLAS:   /sw/pkgs/arc/stacks/gcc/10.3.0/R/4.3.1/lib64/R/lib/libRblas.so 
## LAPACK: /sw/pkgs/arc/stacks/gcc/10.3.0/R/4.3.1/lib64/R/lib/libRlapack.so;  LAPACK version 3.11.0
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## time zone: America/Detroit
## tzcode source: system (glibc)
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] lubridate_1.9.2 tidyr_1.3.0     dplyr_1.1.3     readr_2.1.4    
## [5] knitr_1.44     
## 
## loaded via a namespace (and not attached):
##  [1] crayon_1.5.2     vctrs_0.6.3      cli_3.6.1        rlang_1.1.1     
##  [5] xfun_0.40        purrr_1.0.2      generics_0.1.3   jsonlite_1.8.7  
##  [9] bit_4.0.5        glue_1.6.2       htmltools_0.5.6  sass_0.4.7      
## [13] hms_1.1.3        fansi_1.0.4      rmarkdown_2.25   evaluate_0.21   
## [17] jquerylib_0.1.4  tibble_3.2.1     tzdb_0.4.0       fastmap_1.1.1   
## [21] yaml_2.3.7       lifecycle_1.0.3  compiler_4.3.1   timechange_0.2.0
## [25] pkgconfig_2.0.3  digest_0.6.33    R6_2.5.1         tidyselect_1.2.0
## [29] utf8_1.2.3       parallel_4.3.1   vroom_1.6.3      pillar_1.9.0    
## [33] magrittr_2.0.3   bslib_0.5.1      bit64_4.0.5      tools_4.3.1     
## [37] cachem_1.0.8
```
