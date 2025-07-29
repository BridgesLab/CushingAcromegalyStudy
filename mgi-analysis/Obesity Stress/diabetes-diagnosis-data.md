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

The Elixhauser comorbidity index uses a combination of type 1 and type 2 diabetes with and without co-morbidities to generate its data.  We want to separately identify type 2 diabetes diagnoses. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy/2023-03-14/2150 - Obesity and Stress - Cohort - DeID - 2023-03-14 and was most recently run on Mon Jul 28 17:01:35 2025.


``` r
library(knitr)
#figures made will go to directory called figures, will make them as both png and pdf files 
opts_chunk$set(fig.path='figures/',
               echo=TRUE, warning=FALSE, message=FALSE,dev=c('png','pdf'))
options(scipen = 2, digits = 3)

diagnosis.datafile <- 'ClarityMedicalHistory.csv'
encounters.datafile <- 'EncounterAll.csv'
```

The encounter datafile is in EncounterAll.csv with the diagnosis data from ClarityMedicalHistory in thee file `r `diagnosis.datafile`. This latter file includes the participant, encounter, date, ICD lexicon (ICD9 or ICD10) the actual code and the name for the code.


``` r
library(readr)
library(dplyr)
library(tidyr)
library(knitr)
library(lubridate)

#get diagnosis data
diagnosis.data <- read_csv(diagnosis.datafile) 
  
diagnosis.data <- 
  diagnosis.data %>%
  mutate(DeID_ProblemObservationDate=mdy_hm(DeID_ProblemObservationDate))
```

For ICD10 codes (see https://edit.cms.gov/files/document/valid-icd-10-list.xlsx), all Type 2 Diabetes codes start with *E11* and include the phrase "Type 2"

For ICD9 codes (see https://edit.cms.gov/files/document/valid-icd-9-list.xlsx), all type 2 diabetes codes contain the words type II and Diabetes though in different orders


``` r
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


``` r
#this generates a list of all participants with at least one ID
diabetic.participants <-
  diabetes.diagnoses %>%
  arrange(DeID_ProblemObservationDate) %>% #sort by first observation
  select(DeID_ProblemObservationDate,DeID_PatientID) %>% #keep just these columns
  rename(DeID_Diabetes_Diagnosis=DeID_ProblemObservationDate) %>%
  distinct(DeID_PatientID,.keep_all=T)  
```

There was a total of 16221 that we identified as having type 2 diabetes

# Comparison to Elixhauser Comorbidities Index


``` r
comorbidity.datafile <- 'ComorbiditiesElixhauserComprehensive.csv'
comorbidity.data <- read_csv(comorbidity.datafile)

comorbidity.diabetics <-
  comorbidity.data %>%
  filter(DiabetesUncomplicated=='1'|DiabetesComplicated=='1') %>%
  distinct(DeID_PatientID)
```

From the Elixhauser data there were 19925 people with diabetes combining those with and without complications.  This may be either type 1 or type 2.

## What percent of all elixhauser diabetic participants had type 2 diabetes?


``` r
comorbidity.diabetics$DeID_PatientID %in% diabetic.participants$DeID_PatientID %>%
  table %>%
  kable(caption="Number of Elixhauser diabetics identified by IC9/10 codes, these could be type 1")
```



Table: Number of Elixhauser diabetics identified by IC9/10 codes, these could be type 1

|.     |  Freq|
|:-----|-----:|
|FALSE |  3919|
|TRUE  | 16006|

``` r
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


``` r
combined.data <-
  comorbidity.data %>%
  full_join(diabetic.participants,by='DeID_PatientID') %>%
  mutate(Type2Diabetes = case_when(DeID_PatientID %in% diabetic.participants$DeID_PatientID ~ '1',
                                   TRUE~'0'))
  
output.file <- 'ComorbidityDataAnnotated.csv'
write_csv(combined.data, file=output.file)
```

These data were written out to ComorbidityDataAnnotated.csv. This is the input file for the other scripts.

# Session Information


``` r
sessionInfo()
```

```
## R version 4.4.3 (2025-02-28)
## Platform: x86_64-pc-linux-gnu
## Running under: Red Hat Enterprise Linux 8.10 (Ootpa)
## 
## Matrix products: default
## BLAS:   /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.3/lib64/R/lib/libRblas.so 
## LAPACK: /sw/pkgs/arc/stacks/gcc/13.2.0/R/4.4.3/lib64/R/lib/libRlapack.so;  LAPACK version 3.12.0
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
## [1] lubridate_1.9.3 tidyr_1.3.1     dplyr_1.1.4     readr_2.1.5    
## [5] knitr_1.48     
## 
## loaded via a namespace (and not attached):
##  [1] bit_4.0.5         jsonlite_1.8.8    compiler_4.4.3    crayon_1.5.3     
##  [5] tidyselect_1.2.1  parallel_4.4.3    jquerylib_0.1.4   yaml_2.3.9       
##  [9] fastmap_1.2.0     R6_2.5.1          generics_0.1.3    tibble_3.2.1     
## [13] bslib_0.7.0       pillar_1.9.0      tzdb_0.4.0        rlang_1.1.4      
## [17] utf8_1.2.4        cachem_1.1.0      xfun_0.45         sass_0.4.9       
## [21] bit64_4.0.5       timechange_0.3.0  cli_3.6.3         withr_3.0.0      
## [25] magrittr_2.0.3    digest_0.6.36     vroom_1.6.5       hms_1.1.3        
## [29] lifecycle_1.0.4   vctrs_0.6.5       evaluate_0.24.0   glue_1.8.0       
## [33] fansi_1.0.6       rmarkdown_2.27    purrr_1.0.2       tools_4.4.3      
## [37] pkgconfig_2.0.3   htmltools_0.5.8.1
```
