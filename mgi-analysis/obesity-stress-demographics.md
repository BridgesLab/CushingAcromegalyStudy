---
title: "Summary of Demographic Factors for Stress and Obesity Relationships"
author: "Dave Bridges"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: yes
    toc: yes
---

## Purpose

To define covariates for stress-obesity relationships.


```r
library(knitr)
#figures made will go to directory called figures, will make them as both png and pdf files 
opts_chunk$set(fig.path='figures/',
               echo=TRUE, warning=FALSE, message=FALSE,dev=c('png','pdf'))
options(scipen = 2, digits = 3)

library(readr)
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(tidyr)

input.file <- 'data-combined.csv'
combined.data <- read_csv(input.file)%>%
  filter(!(is.na(HypertensionAny))) %>%
  filter(!(is.na(Stress))) %>%
  filter(Stress!="NA") %>%
  mutate(BMI_cat= factor(BMI_cat, 
                         levels=c("Underweight",
                                  "Normal",
                                  "Overweight",
                                  'Class I Obese',
                                  'Class II Obese',
                                  'Class III Obese'))) %>%
  mutate(BMI_cat.obese= factor(BMI_cat.obese, 
                               levels=c("Underweight",
                                        "Normal",
                                        "Overweight",
                                        'Obese'))) %>%
  mutate(BMI_cat.Ob.NonOb= factor(BMI_cat.Ob.NonOb, 
                                  levels=c("Non-Obese",
                                           'Obese'))) %>%
  mutate(Stress=relevel(as.factor(High.Stress),ref="Low"))
```

```
## Rows: 62010 Columns: 39
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (17): DeID_PatientID, Gender, DeID_EncounterID, BMI_cat, BMI_cat.obese, ...
## dbl (22): age, Stress_d1, CardiacArrhythmias, ChronicPulmonaryDisease, Conge...
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Loaded in the cleaned data from data-combined.csv. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy/2023-03-14/2150 - Obesity and Stress - Cohort - DeID - 2023-03-14 and was most recently run on Mon Sep 25 15:02:58 2023. This dataset has 39694 values.

# Summary of Demographic Covariates

Stratified data by stress and obesity status and summarized data

# Total Participants

## By Race and Ethnicity


```r
combined.data %>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  group_by(Race.Ethnicity) %>%
  count %>%
  arrange(desc(n)) %>%
  knitr::kable(caption="Number of participants by all race/ethnicity")
```



Table: Number of participants by all race/ethnicity

|Race.Ethnicity  |     n|
|:---------------|-----:|
|White           | 35321|
|Black           |  1739|
|Other           |  1276|
|Hispanic/Latino |   778|
|Asian           |   580|

### Race and Ethnicity Groupings

Here is all the races currently marked as other


```r
combined.data %>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  filter(Race.Ethnicity =="Other") %>%
  group_by(Race.Ethnicity.Code) %>%
  count %>%
  arrange(desc(n)) %>%
  knitr::kable(caption="Number of participants by race/ethnicity, grouped into the other category")
```



Table: Number of participants by race/ethnicity, grouped into the other category

|Race.Ethnicity.Code |   n|
|:-------------------|---:|
|O-NonHL             | 303|
|U-U                 | 188|
|AI-NonHL            | 175|
|U-NonHL             | 162|
|C-D                 |  81|
|NA-NA               |  59|
|D-NonHL             |  55|
|D-D                 |  51|
|C-NA                |  37|
|P-NonHL             |  28|
|AA-HL               |  20|
|AA-U                |  19|
|NA-NonHL            |  18|
|AI-HL               |  13|
|U-HL                |  11|
|A-U                 |  10|
|O-U                 |   9|
|D-HL                |   6|
|O-D                 |   6|
|AA-D                |   4|
|A-D                 |   3|
|NA-U                |   3|
|A-NA                |   2|
|AI-U                |   2|
|D-U                 |   2|
|NA-D                |   2|
|O-NA                |   2|
|A-HL                |   1|
|AA-NA               |   1|
|AI-D                |   1|
|AI-NA               |   1|
|U-D                 |   1|

## By Gender


```r
combined.data %>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  group_by(Gender) %>%
  count %>%
  arrange(desc(n)) %>%
  knitr::kable(caption="Number of participants by all gender")
```



Table: Number of participants by all gender

|Gender |     n|
|:------|-----:|
|F      | 20866|
|M      | 18828|

## By Age

The average age of our participants is 52.867 with a standard deviation of 16.527.


```r
combined.data %>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  group_by(Age.group) %>%
  count %>%
  arrange(desc(n)) %>%
  knitr::kable(caption="Number of participants by age group")
```



Table: Number of participants by age group

|Age.group |    n|
|:---------|----:|
|(60,70]   | 9172|
|(50,60]   | 8917|
|(40,50]   | 6325|
|(30,40]   | 4832|
|(18,30]   | 4495|
|(70,80]   | 4447|
|(80,90]   | 1087|
|NA        |  419|

## By Body Mass Index

The average BMI of our participants is 29.886 with a standard deviation of 7.036.


```r
combined.data %>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  group_by(BMI_cat) %>%
  count %>%
  arrange(desc(n)) %>%
  knitr::kable(caption="Number of participants by BMI group")
```



Table: Number of participants by BMI group

|BMI_cat         |     n|
|:---------------|-----:|
|Overweight      | 12910|
|Normal          |  9648|
|Class I Obese   |  8870|
|Class II Obese  |  4471|
|Class III Obese |  3378|
|Underweight     |   283|
|NA              |   134|

# Stratifying by Stress and BMI

Grouped by stress and BMI and tested for differences in demographic factors.


```r
combined.data %>%
  group_by(Stress,BMI_cat.Ob.NonOb) %>%
  count %>%
  knitr::kable(caption="Number of participants by group")
```



Table: Number of participants by group

|Stress |BMI_cat.Ob.NonOb |     n|
|:------|:----------------|-----:|
|Low    |Non-Obese        | 13670|
|Low    |Obese            |  9223|
|High   |Non-Obese        |  9305|
|High   |Obese            |  7496|

```r
combined.data %>%
  group_by(Stress,BMI_cat.Ob.NonOb,Gender) %>%
  count %>%
    filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  knitr::kable(caption="Number of participants by group and gender")
```



Table: Number of participants by group and gender

|Stress |BMI_cat.Ob.NonOb |Gender |    n|
|:------|:----------------|:------|----:|
|Low    |Non-Obese        |F      | 6913|
|Low    |Non-Obese        |M      | 6757|
|Low    |Obese            |F      | 4676|
|Low    |Obese            |M      | 4547|
|High   |Non-Obese        |F      | 5005|
|High   |Non-Obese        |M      | 4300|
|High   |Obese            |F      | 4272|
|High   |Obese            |M      | 3224|

```r
combined.data %>%
  group_by(BMI_cat.Ob.NonOb,Stress) %>%
    filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  summarize_at(c('BMI','Stress_d1'), list(mean=~mean(.x,na.rm=T),
                                    sd=~sd(.x,na.rm=T),
                                    n=~length(.x)))%>%
  knitr::kable(caption="Average BMI and age of participants by group")
```



Table: Average BMI and age of participants by group

|BMI_cat.Ob.NonOb |Stress | BMI_mean| Stress_d1_mean| BMI_sd| Stress_d1_sd| BMI_n| Stress_d1_n|
|:----------------|:------|--------:|--------------:|------:|------------:|-----:|-----------:|
|Non-Obese        |Low    |     25.3|           2.34|   2.98|         1.75| 13670|       13670|
|Non-Obese        |High   |     25.2|           8.04|   3.13|         1.78|  9305|        9305|
|Obese            |Low    |     36.0|           2.43|   5.72|         1.75|  9223|        9223|
|Obese            |High   |     36.6|           8.16|   6.00|         1.85|  7496|        7496|

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
## [1] tidyr_1.3.0 dplyr_1.1.3 readr_2.1.4 knitr_1.44 
## 
## loaded via a namespace (and not attached):
##  [1] crayon_1.5.2     vctrs_0.6.3      cli_3.6.1        rlang_1.1.1     
##  [5] xfun_0.40        purrr_1.0.2      generics_0.1.3   jsonlite_1.8.7  
##  [9] bit_4.0.5        glue_1.6.2       htmltools_0.5.6  sass_0.4.7      
## [13] hms_1.1.3        fansi_1.0.4      rmarkdown_2.25   evaluate_0.21   
## [17] jquerylib_0.1.4  tibble_3.2.1     tzdb_0.4.0       fastmap_1.1.1   
## [21] yaml_2.3.7       lifecycle_1.0.3  compiler_4.3.1   pkgconfig_2.0.3 
## [25] digest_0.6.33    R6_2.5.1         tidyselect_1.2.0 utf8_1.2.3      
## [29] parallel_4.3.1   vroom_1.6.3      pillar_1.9.0     magrittr_2.0.3  
## [33] bslib_0.5.1      withr_2.5.0      bit64_4.0.5      tools_4.3.1     
## [37] cachem_1.0.8
```
