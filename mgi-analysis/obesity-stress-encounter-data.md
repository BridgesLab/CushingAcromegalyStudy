---
title: "Summarizing the Encounter Level Data to Define BMI"
author: "Dave Bridges"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: yes
    toc: yes
---

## Purpose

To test the effect modification of obesity on the stress-diabetes relationships. This script collects the the raw data files, processes and merges them. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy/2023-03-14/2150 - Obesity and Stress - Cohort - DeID - 2023-03-14 and was most recently run on Wed Sep 20 13:47:57 2023.


```r
library(knitr)
#figures made will go to directory called figures, will make them as both png and pdf files 
opts_chunk$set(fig.path='figures/',
               echo=TRUE, warning=FALSE, message=FALSE,dev=c('png','pdf'))
options(scipen = 2, digits = 3)

encounters.datafile <- 'EncounterAnthropometricsBMI.csv'
encounters.datefile <- 'EncounterAll.csv'
```

The input data file is in EncounterAnthropometricsBMI.csv. This includes the BMI for each patient, potentially at multiple time points. This script takes this file and pulls out just the first BMI measure


```r
library(readr)
library(dplyr)
library(tidyr)
library(knitr)

#get encounter data
bmi.data.raw <- read_csv(encounters.datafile) 
encounter.data <- read_csv(encounters.datefile)

library(lubridate)
#annotating bmi data with encounters
bmi.data <- 
  left_join(bmi.data.raw,encounter.data,by=c('DeID_PatientID','DeID_EncounterID')) %>%
  mutate(EncounterDate = mdy_hm(DeID_AdmitDate))%>%
  mutate(EncounterYear = year(EncounterDate)) 
```

# Summarizing BMI Data


```r
library(ggplot2)

ggplot(bmi.data,
       aes(x=EncounterYear)) +
  geom_bar() +
  theme_classic() +
  scale_fill_grey() +
  labs(y="Encounters",
       x="Year") +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.75))
```

![](figures/encounter-range-1.png)<!-- -->

```r
bmi.data %>%
  group_by(EncounterYear) %>%
  count %>%
  kable(caption="Total Encoutners by Year")
```



Table: Total Encoutners by Year

| EncounterYear|       n|
|-------------:|-------:|
|          1900|       2|
|          1922|       3|
|          1931|       2|
|          1950|       1|
|          1952|       2|
|          1961|       1|
|          1962|       2|
|          1965|       1|
|          1967|       1|
|          1968|       1|
|          1969|       1|
|          1970|       1|
|          1971|       3|
|          1972|       2|
|          1973|       1|
|          1974|       2|
|          1975|       5|
|          1976|       3|
|          1977|       4|
|          1978|       4|
|          1979|       2|
|          1980|       4|
|          1981|       2|
|          1982|       4|
|          1983|       5|
|          1984|       2|
|          1985|      13|
|          1986|      13|
|          1987|      17|
|          1988|      32|
|          1989|      58|
|          1990|      88|
|          1991|      96|
|          1992|     110|
|          1993|     116|
|          1994|     175|
|          1995|     277|
|          1996|     357|
|          1997|    1134|
|          1998|    2913|
|          1999|    8314|
|          2000|   65938|
|          2001|   62736|
|          2002|   67723|
|          2003|   75961|
|          2004|   84505|
|          2005|   94869|
|          2006|  185402|
|          2007|  219371|
|          2008|  238403|
|          2009|  262719|
|          2010|  288540|
|          2011|  401934|
|          2012| 1944953|
|          2013| 2790942|
|          2014| 2338739|
|          2015| 2420047|
|          2016| 2415482|
|          2017| 2174851|
|          2018| 3224052|
|          2019| 3255967|
|          2020| 2920087|
|          2021| 3052931|
|          2022| 2815766|
|          2023|  210723|
|          2024|    2016|
|          2025|     254|
|          2026|     695|
|          2027|     314|
|          2028|       8|
|          2029|       5|
|          2030|       1|
|          2032|       1|
|          2043|       1|
|          2108|       6|
|          2109|       4|
|            NA| 2067630|

## Time of Follow Up


```r
follow.up.data <-
  bmi.data %>%
  filter(!(is.na(EncounterDate))) %>%
  #filter(EncounterDate>today()) %>% #implausible follow up
  arrange(DeID_PatientID,EncounterDate) %>%
  group_by(DeID_PatientID) %>%
  summarize(First= first(EncounterDate),
            Last = last(EncounterDate)) %>%
  mutate(FollowUp = round(time_length(date(Last)-date(First),unit="years"),0),
         FollowUpNow = round(time_length(as.Date(today()) -date(First),unit="years"),0)) 

follow.up.data %>%
  group_by(FollowUp) %>%
  count %>% 
  ungroup %>%
  arrange(-FollowUp) %>%
  mutate(cumulative = cumsum(n)) %>%
  kable(caption="Participant follow up duration")
```



Table: Participant follow up duration

| FollowUp|    n| cumulative|
|--------:|----:|----------:|
|      118|    1|          1|
|      116|    1|          2|
|      111|    1|          3|
|      108|    1|          4|
|      105|    1|          5|
|      102|    1|          6|
|      101|    1|          7|
|       96|    1|          8|
|       93|    1|          9|
|       92|    1|         10|
|       91|    1|         11|
|       73|    1|         12|
|       71|    1|         13|
|       69|    1|         14|
|       62|    1|         15|
|       61|    1|         16|
|       58|    1|         17|
|       56|    1|         18|
|       53|    2|         20|
|       52|    1|         21|
|       50|    2|         23|
|       49|    1|         24|
|       48|    4|         28|
|       47|    5|         33|
|       46|    3|         36|
|       45|    2|         38|
|       44|    4|         42|
|       43|    4|         46|
|       42|    3|         49|
|       41|    4|         53|
|       40|    5|         58|
|       39|    7|         65|
|       38|    7|         72|
|       37|    6|         78|
|       36|   13|         91|
|       35|   22|        113|
|       34|   34|        147|
|       33|   33|        180|
|       32|   42|        222|
|       31|   37|        259|
|       30|   46|        305|
|       29|  104|        409|
|       28|  125|        534|
|       27|  279|        813|
|       26|  622|       1435|
|       25| 1392|       2827|
|       24| 3149|       5976|
|       23| 6385|      12361|
|       22| 3607|      15968|
|       21| 2633|      18601|
|       20| 2394|      20995|
|       19| 2368|      23363|
|       18| 2322|      25685|
|       17| 2498|      28183|
|       16| 2444|      30627|
|       15| 2231|      32858|
|       14| 2275|      35133|
|       13| 2176|      37309|
|       12| 3183|      40492|
|       11| 5512|      46004|
|       10| 3337|      49341|
|        9| 3552|      52893|
|        8| 3993|      56886|
|        7| 4285|      61171|
|        6| 4544|      65715|
|        5| 4962|      70677|
|        4| 4743|      75420|
|        3| 4074|      79494|
|        2| 4209|      83703|
|        1| 5161|      88864|
|        0| 2734|      91598|

```r
ggplot(follow.up.data,
       aes(x=FollowUp)) +
  geom_bar() +
  theme_classic() +
  scale_fill_grey() +
  labs(y="Participants",
       x="Years of Follow Up") +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.75))
```

![](figures/encounter-followup-1.png)<!-- -->

The average follow up period is NA.

# Defining BMI Data

We will use the median BMI measure if there are multiple in the encounters file.


```r
bmi.cutoff <- 300
bmi.lower <- 12

bmi.data.median <- 
  bmi.data %>%
  group_by(DeID_PatientID) %>%
  summarize(BMI = median(BMI,na.rm=T),
            BMI.n = length(BMI)) 

bmi.data.complete <-
  bmi.data.median %>%
  filter(!(is.na(BMI)))  # remove rows where there is no BMI data

bmi.data.cutoff <-
  bmi.data.complete %>%
  filter(BMI<bmi.cutoff) %>% #remove BMI under cutoff
  filter(BMI>bmi.lower) #remove BMI above cutoff
```

Based on this procedure we had 91598 participants in the initial dataset.  After removing individuals with no BMI measure we had 90245 (a loss of 1353 participants).  We then removed anyone who's median BMI was >300 or <12, a loss of 3 participants.  This resulted in a final dataset of 90242.

## Analysis of BMI


```r
library(ggplot2)
bmi.data.cutoff %>%
  ggplot(aes(x=BMI)) +
  geom_density() +
  theme_classic() +
  scale_fill_grey() +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.85))
```

![](figures/bmi-analysis-1.png)<!-- -->

```r
bmi.data.cutoff %>%
  ggplot(aes(x=BMI)) +
  geom_histogram() +
  theme_classic() +
  scale_fill_grey() +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.85))
```

![](figures/bmi-analysis-2.png)<!-- -->

```r
bmi.data.cutoff %>%
  summarize(mean=mean(BMI,na.rm=T),
             min=min(BMI, na.rm=T),
             max=max(BMI,na.rm=T),
             sd=sd(BMI,na.rm=T),
             n=length(BMI)) %>%
  kable(caption="Summary statistics for the BMI measurements used in this study")
```



Table: Summary statistics for the BMI measurements used in this study

| mean|  min| max|  sd|     n|
|----:|----:|---:|---:|-----:|
| 29.8| 12.3| 100| 7.2| 90242|

# Validation and Checking for Outliers

We filtered out all BMI that the median was \>300. After this the highest and lowest BMI were


```r
bmi.data.cutoff %>%
  arrange(desc(BMI)) %>%
  select(BMI,BMI.n) %>%
  head(10) %>%
  kable(caption="Top 50 median BMI values and number of encounters")
```



Table: Top 50 median BMI values and number of encounters

|   BMI| BMI.n|
|-----:|-----:|
| 100.3|     1|
|  99.4|     1|
|  97.6|     1|
|  94.1|     1|
|  92.2|     1|
|  91.1|     1|
|  87.2|     1|
|  86.8|     1|
|  79.8|     1|
|  79.7|     1|

```r
bmi.data.cutoff %>%
  arrange(BMI) %>%
  select(BMI,BMI.n) %>%
  head(10) %>%
  kable(caption="Top 50 median BMI values and number of encounters")
```



Table: Top 50 median BMI values and number of encounters

|  BMI| BMI.n|
|----:|-----:|
| 12.3|     1|
| 12.5|     1|
| 12.6|     1|
| 13.0|     1|
| 13.2|     1|
| 13.6|     1|
| 13.6|     1|
| 13.7|     1|
| 14.1|     1|
| 14.1|     1|

# Output


```r
output.file <- 'MedianEncounterAnthropometricsBMI.csv'
write_csv(bmi.data.cutoff, file=output.file)
```

These data were written out to MedianEncounterAnthropometricsBMI.csv. This is the input file for the other scripts.

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
## [1] ggplot2_3.4.3   lubridate_1.9.2 tidyr_1.3.0     dplyr_1.1.3    
## [5] readr_2.1.4     knitr_1.44     
## 
## loaded via a namespace (and not attached):
##  [1] bit_4.0.5        gtable_0.3.4     jsonlite_1.8.7   compiler_4.3.1  
##  [5] crayon_1.5.2     tidyselect_1.2.0 parallel_4.3.1   jquerylib_0.1.4 
##  [9] scales_1.2.1     yaml_2.3.7       fastmap_1.1.1    R6_2.5.1        
## [13] labeling_0.4.3   generics_0.1.3   tibble_3.2.1     munsell_0.5.0   
## [17] bslib_0.5.1      pillar_1.9.0     tzdb_0.4.0       rlang_1.1.1     
## [21] utf8_1.2.3       cachem_1.0.8     xfun_0.40        sass_0.4.7      
## [25] bit64_4.0.5      timechange_0.2.0 cli_3.6.1        withr_2.5.0     
## [29] magrittr_2.0.3   grid_4.3.1       digest_0.6.33    vroom_1.6.3     
## [33] hms_1.1.3        lifecycle_1.0.3  vctrs_0.6.3      evaluate_0.21   
## [37] glue_1.6.2       farver_2.1.1     colorspace_2.1-0 fansi_1.0.4     
## [41] rmarkdown_2.25   purrr_1.0.2      tools_4.3.1      pkgconfig_2.0.3 
## [45] htmltools_0.5.6
```
