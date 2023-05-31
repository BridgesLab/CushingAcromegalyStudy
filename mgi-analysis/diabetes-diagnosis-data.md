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

The Elixhauser comorbidity index uses a combination of type 1 and type 2 diabetes with and without co-morbidities to generate its data.  We want to separately identify type 2 diabetes diagnoses. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy/2023-03-14/2150 - Obesity and Stress - Cohort - DeID - 2023-03-14 and was most recently run on Tue May 30 21:13:17 2023.


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
diagnosis.data<- read_csv(diagnosis.datafile) %>%
  mutate(DeID_ProblemObservationDate=ymd_hms(DeID_ProblemObservationDate))
```

For ICD10 codes (see https://edit.cms.gov/files/document/valid-icd-10-list.xlsx), all Type 2 Diabetes codes start with *E11* and include the phrase "Type 2"

For ICD9 codes (see https://edit.cms.gov/files/document/valid-icd-9-list.xlsx), all type 2 diabetes codes contain the words type II and Diabetes though in different orders


```r
diabetes.diagnoses.icd10 <- 
  diagnosis.data %>%
  filter(grepl('Type 2 diabetes', DiagnosisICDNameMapped))

diabetes.diagnoses.icd9 <-
  diagnosis.data %>%
  filter(grepl('type II',DiagnosisICDNameMapped)) %>% #includes all diseases marked type II
  filter(grepl('Diabetes',DiagnosisICDNameMapped)) #includes only those that contain diabetes in the name

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

There was a total of 16070 that we identified as having type 2 diabetes

# Comparison to Elixhauser Comorbidities Index


```r
comorbidity.datafile <- 'ComorbiditiesElixhauserComprehensive.csv'
comorbidity.data <- read_csv(comorbidity.datafile)

comorbidity.diabetics <-
  comorbidity.data %>%
  filter(DiabetesUncomplicated=='1'|DiabetesComplicated=='1') %>%
  distinct(DeID_PatientID)
```

From the Elixhauser data there were 19925 people with diabetes (either type 1 or type 2).

## What percent of all elixhauser diabetic participants had type 2 diabetes?


```r
comorbidity.diabetics$DeID_PatientID %in% diabetic.participants$DeID_PatientID %>%
  table %>%
  kable(caption="Number of Elixhauser diabetics identified by charts")
```



Table: Number of Elixhauser diabetics identified by charts

|.     |  Freq|
|:-----|-----:|
|FALSE |  4069|
|TRUE  | 15856|

Among the participants who were elixhauser diabetic, but charted negative we expect some of these should be type I, among the remainder the charted diagnoses included the following


```r
comorbidity.diabetics %>%
  filter(!(DeID_PatientID %in% diabetic.participants$DeID_PatientID)) %>%
  distinct(DeID_PatientID) -> comorbidity.not.chart

diagnosis.data %>%
  filter(DeID_PatientID %in% comorbidity.not.chart) %>% #patients with uncharted comorbidities, but do have diabetes according to elixhauser
  filter(grepl('[Dd]iabete[sic]',DiagnosisICDNameMapped)) %>% #contains the word diabetes or diabetic in either case
  group_by(DiagnosisICDNameMapped) %>%
  count %>%
  arrange(desc(n)) %>%
  kable(caption="Common diagnoses related to diabetes present in elixhauser tables, but not chart abstractions")
```



Table: Common diagnoses related to diabetes present in elixhauser tables, but not chart abstractions

|DiagnosisICDNameMapped |  n|
|:----------------------|--:|


## What percent of type 2 diabetic participants were found in Elixhauser?


```r
diabetic.participants$DeID_PatientID %in% comorbidity.diabetics$DeID_PatientID  %>% 
  table %>%
  kable(caption="Number of charted diabetics identified by Elixhauser tables")
```



Table: Number of charted diabetics identified by Elixhauser tables

|.     |  Freq|
|:-----|-----:|
|FALSE |   214|
|TRUE  | 15856|

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
## R version 4.2.0 (2022-04-22)
## Platform: x86_64-pc-linux-gnu (64-bit)
## Running under: Red Hat Enterprise Linux 8.4 (Ootpa)
## 
## Matrix products: default
## BLAS:   /sw/pkgs/arc/stacks/gcc/10.3.0/R/4.2.0/lib64/R/lib/libRblas.so
## LAPACK: /sw/pkgs/arc/stacks/gcc/10.3.0/R/4.2.0/lib64/R/lib/libRlapack.so
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] lubridate_1.9.0  timechange_0.1.1 tidyr_1.2.1      dplyr_1.0.10    
## [5] readr_2.1.3      knitr_1.41      
## 
## loaded via a namespace (and not attached):
##  [1] highr_0.9        pillar_1.8.1     bslib_0.4.1      compiler_4.2.0  
##  [5] jquerylib_0.1.4  tools_4.2.0      bit_4.0.5        digest_0.6.30   
##  [9] jsonlite_1.8.4   evaluate_0.18    lifecycle_1.0.3  tibble_3.1.8    
## [13] pkgconfig_2.0.3  rlang_1.0.6      cli_3.4.1        DBI_1.1.3       
## [17] parallel_4.2.0   yaml_2.3.6       xfun_0.35        fastmap_1.1.0   
## [21] stringr_1.5.0    generics_0.1.3   vctrs_0.5.1      sass_0.4.4      
## [25] hms_1.1.2        bit64_4.0.5      tidyselect_1.2.0 glue_1.6.2      
## [29] R6_2.5.1         fansi_1.0.3      vroom_1.6.0      rmarkdown_2.18  
## [33] tzdb_0.3.0       purrr_0.3.5      magrittr_2.0.3   ellipsis_0.3.2  
## [37] htmltools_0.5.4  assertthat_0.2.1 utf8_1.2.2       stringi_1.7.8   
## [41] cachem_1.0.6     crayon_1.5.2
```
