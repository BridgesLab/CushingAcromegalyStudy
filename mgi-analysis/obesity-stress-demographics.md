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
## Rows: 62010 Columns: 32
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (16): DeID_PatientID, Gender, DeID_EncounterID, BMI_cat, BMI_cat.obese, ...
## dbl (16): age, Stress_d1, CardiacArrhythmias, ChronicPulmonaryDisease, Depre...
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Loaded in the cleaned data from data-combined.csv. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy and was most recently run on Thu Mar  9 16:02:38 2023. This dataset has 39691 values.

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
|White           | 35322|
|Black           |  1738|
|Other           |  1268|
|Hispanic/Latino |   779|
|Asian           |   584|

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
|O-NonHL             | 302|
|U-U                 | 187|
|AI-NonHL            | 174|
|U-NonHL             | 161|
|C-D                 |  81|
|NA-NA               |  58|
|D-NonHL             |  55|
|D-D                 |  51|
|C-NA                |  38|
|P-NonHL             |  28|
|AA-HL               |  20|
|AA-U                |  19|
|NA-NonHL            |  15|
|AI-HL               |  12|
|U-HL                |  11|
|A-U                 |  10|
|O-U                 |  10|
|D-HL                |   6|
|O-D                 |   6|
|AA-D                |   4|
|A-D                 |   3|
|A-NA                |   2|
|AI-U                |   2|
|D-U                 |   2|
|NA-D                |   2|
|NA-U                |   2|
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
|F      | 20863|
|M      | 18828|

## By Age

The average age of our participants is 52.866 with a standard deviation of 16.526.


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
|(50,60]   | 8916|
|(40,50]   | 6325|
|(30,40]   | 4833|
|(18,30]   | 4494|
|(70,80]   | 4445|
|(80,90]   | 1087|
|NA        |  419|

## By Body Mass Index

The average BMI of our participants is 29.889 with a standard deviation of 7.04.


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
|Overweight      | 12892|
|Normal          |  9654|
|Class I Obese   |  8876|
|Class II Obese  |  4472|
|Class III Obese |  3380|
|Underweight     |   282|
|NA              |   135|

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
|Low    |Non-Obese        | 13662|
|Low    |Obese            |  9229|
|High   |Non-Obese        |  9301|
|High   |Obese            |  7499|

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
|Low    |Non-Obese        |F      | 6906|
|Low    |Non-Obese        |M      | 6756|
|Low    |Obese            |F      | 4680|
|Low    |Obese            |M      | 4549|
|High   |Non-Obese        |F      | 5006|
|High   |Non-Obese        |M      | 4295|
|High   |Obese            |F      | 4271|
|High   |Obese            |M      | 3228|

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
|Non-Obese        |Low    |     25.3|           2.34|   2.98|         1.75| 13662|       13662|
|Non-Obese        |High   |     25.1|           8.04|   3.13|         1.78|  9301|        9301|
|Obese            |Low    |     36.0|           2.43|   5.72|         1.75|  9229|        9229|
|Obese            |High   |     36.6|           8.16|   6.00|         1.85|  7499|        7499|

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
## [1] tidyr_1.2.1  dplyr_1.0.10 readr_2.1.3  knitr_1.41  
## 
## loaded via a namespace (and not attached):
##  [1] highr_0.9        pillar_1.8.1     bslib_0.4.1      compiler_4.2.0  
##  [5] jquerylib_0.1.4  tools_4.2.0      bit_4.0.5        digest_0.6.30   
##  [9] jsonlite_1.8.4   evaluate_0.18    lifecycle_1.0.3  tibble_3.1.8    
## [13] pkgconfig_2.0.3  rlang_1.0.6      cli_3.4.1        DBI_1.1.3       
## [17] parallel_4.2.0   yaml_2.3.6       xfun_0.35        fastmap_1.1.0   
## [21] withr_2.5.0      stringr_1.5.0    generics_0.1.3   vctrs_0.5.1     
## [25] sass_0.4.4       hms_1.1.2        bit64_4.0.5      tidyselect_1.2.0
## [29] glue_1.6.2       R6_2.5.1         fansi_1.0.3      vroom_1.6.0     
## [33] rmarkdown_2.18   tzdb_0.3.0       purrr_0.3.5      magrittr_2.0.3  
## [37] ellipsis_0.3.2   htmltools_0.5.4  assertthat_0.2.1 utf8_1.2.2      
## [41] stringi_1.7.8    cachem_1.0.6     crayon_1.5.2
```
