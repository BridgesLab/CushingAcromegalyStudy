---
title: "Association of Obesity and Stress with Hypertension"
author: "Dave Bridges"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: yes
    toc: yes
editor: visual
---

## Purpose

To test the effect modification of obesity on the stress-hypertension relationships.


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
library(knitr)

input.file <- 'data-combined.csv'
combined.data <- read_csv(input.file, na="-99")%>%
  filter(!(is.na(HypertensionAny))) %>%
  filter(!(is.na(Stress))) %>%
  filter(Stress!="NA")
```

```
## Rows: 62010 Columns: 32
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (17): DeID_PatientID, Gender, Stress_d1, DeID_EncounterID, BMI_cat, BMI_...
## dbl (15): age, CardiacArrhythmias, ChronicPulmonaryDisease, Depression, Diab...
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Loaded in the cleaned data from data-combined.csv. This script can be found in /nfs/turbo/precision-health/DataDirect/HUM00219435 - Obesity as a modifier of chronic psy and was most recently run on Tue Mar  7 15:33:51 2023. This dataset has 39691 values.


```r
combined.data <- 
  combined.data %>%
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
  mutate(Stress=relevel(as.factor(High.Stress),ref="Low"))  #set low as reference value
```

# Hypertension Complication Rates by BMI

Stratified diagnoses by various BMI categories

## Hypertension by BMI Category


```r
#calculating hypertension rates by bmi category
with(combined.data, table(HypertensionAny,BMI_cat,Gender)) %>% 
  data.frame %>%
  pivot_wider(names_from=HypertensionAny,
              values_from = Freq) %>%
  rename(HypertensionAny=`1`,
         NonDisease=`0`) %>%
  mutate(Total=HypertensionAny+NonDisease) %>%
  mutate(Percent=HypertensionAny/Total*100) -> hypertension.bmi.counts

kable(hypertension.bmi.counts, caption="Liver disease rates by BMI category")
```



Table: Liver disease rates by BMI category

|BMI_cat         |Gender | NonDisease| HypertensionAny| Total| Percent|
|:---------------|:------|----------:|---------------:|-----:|-------:|
|Underweight     |F      |        146|              45|   191|    23.6|
|Normal          |F      |       4638|            1197|  5835|    20.5|
|Overweight      |F      |       4029|            1761|  5790|    30.4|
|Class I Obese   |F      |       2484|            1682|  4166|    40.4|
|Class II Obese  |F      |       1376|            1113|  2489|    44.7|
|Class III Obese |F      |       1122|            1174|  2296|    51.1|
|Underweight     |M      |         69|              22|    91|    24.2|
|Normal          |M      |       2741|            1078|  3819|    28.2|
|Overweight      |M      |       4247|            2855|  7102|    40.2|
|Class I Obese   |M      |       2257|            2453|  4710|    52.1|
|Class II Obese  |M      |        794|            1189|  1983|    60.0|
|Class III Obese |M      |        418|             666|  1084|    61.4|

```r
library(ggplot2)

ggplot(hypertension.bmi.counts,
       aes(y=Percent,
           x=BMI_cat)) +
  geom_bar(stat='identity',position='dodge') +
  labs(y="Percent Hypertension",
       title="Effects of Chronic Stress on Hypertension Rates",
       x="") +
  theme_classic() +
  scale_fill_grey() +
  facet_grid(.~Gender) +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.85))
```

![](figures/hypertension-BMI-1.png)<!-- -->

## Hypertension Rate by BMI and Stress

This analysis uses all the BMI categories


```r
#calculating hypertension rates by bmi category and stress
with(combined.data, table(HypertensionAny,BMI_cat,Stress,Gender)) %>% 
  data.frame %>%
  pivot_wider(names_from=HypertensionAny,
              values_from = Freq) %>%
  rename(HypertensionAny=`1`,
         NonHypertensionAny=`0`) %>%
  mutate(Total=HypertensionAny+NonHypertensionAny) %>%
  mutate(Percent=HypertensionAny/Total*100) -> hypertension.bmi.stress.counts

library(ggplot2)

kable(hypertension.bmi.stress.counts, caption="Hypertension rates by BMI category")
```



Table: Hypertension rates by BMI category

|BMI_cat         |Stress |Gender | NonHypertensionAny| HypertensionAny| Total| Percent|
|:---------------|:------|:------|------------------:|---------------:|-----:|-------:|
|Underweight     |Low    |F      |                 71|              22|    93|    23.7|
|Normal          |Low    |F      |               2759|             672|  3431|    19.6|
|Overweight      |Low    |F      |               2352|             974|  3326|    29.3|
|Class I Obese   |Low    |F      |               1329|             879|  2208|    39.8|
|Class II Obese  |Low    |F      |                727|             583|  1310|    44.5|
|Class III Obese |Low    |F      |                561|             601|  1162|    51.7|
|Underweight     |High   |F      |                 75|              23|    98|    23.5|
|Normal          |High   |F      |               1879|             525|  2404|    21.8|
|Overweight      |High   |F      |               1677|             787|  2464|    31.9|
|Class I Obese   |High   |F      |               1155|             803|  1958|    41.0|
|Class II Obese  |High   |F      |                649|             530|  1179|    45.0|
|Class III Obese |High   |F      |                561|             573|  1134|    50.5|
|Underweight     |Low    |M      |                 32|               7|    39|    17.9|
|Normal          |Low    |M      |               1654|             637|  2291|    27.8|
|Overweight      |Low    |M      |               2634|            1773|  4407|    40.2|
|Class I Obese   |Low    |M      |               1364|            1474|  2838|    51.9|
|Class II Obese  |Low    |M      |                458|             671|  1129|    59.4|
|Class III Obese |Low    |M      |                229|             353|   582|    60.7|
|Underweight     |High   |M      |                 37|              15|    52|    28.8|
|Normal          |High   |M      |               1087|             441|  1528|    28.9|
|Overweight      |High   |M      |               1613|            1082|  2695|    40.1|
|Class I Obese   |High   |M      |                893|             979|  1872|    52.3|
|Class II Obese  |High   |M      |                336|             518|   854|    60.7|
|Class III Obese |High   |M      |                189|             313|   502|    62.4|

```r
ggplot(hypertension.bmi.stress.counts,
       aes(y=Percent,
           x=BMI_cat,
           fill=Stress)) +
  geom_bar(stat='identity',position='dodge') +
  labs(y="Percent Hypertension",
       title="Effects of Chronic Stress on Hypertension Rates",
       x="") +
  theme_classic() +
  scale_fill_grey() +
  facet_grid(.~Gender) +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.85))
```

![](figures/hypertension-complicated-BMI-stress-1.png)<!-- -->

### Logistic Regressions for All Obese Categories

Ran a series of stepwise logistic regressions testing for obesity as a modifier of the effects of stress.


```r
library(broom)
glm(HypertensionAny~BMI_cat, 
    family="binomial",
    data=combined.data) -> obesity.glm1

obesity.glm1 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on hypertension", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on hypertension

|term                   | estimate| std.error| statistic|  p.value|
|:----------------------|--------:|---------:|---------:|--------:|
|(Intercept)            |    -1.17|     0.140|     -8.33| 7.87e-17|
|BMI_catNormal          |    -0.01|     0.142|     -0.08| 9.40e-01|
|BMI_catOverweight      |     0.58|     0.141|      4.13| 3.71e-05|
|BMI_catClass I Obese   |     1.03|     0.142|      7.27| 3.54e-13|
|BMI_catClass II Obese  |     1.22|     0.143|      8.56| 1.11e-17|
|BMI_catClass III Obese |     1.34|     0.144|      9.33| 1.11e-20|

```r
anova(obesity.glm1,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on hypertension, ", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on hypertension, 

|term    | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:-------|--:|--------:|---------:|----------:|-------:|
|NULL    | NA|       NA|     39555|      52730|      NA|
|BMI_cat |  5|     1942|     39550|      50788|       0|

```r
#adding in stress as a modifier
glm(HypertensionAny~BMI_cat+Stress+Stress:BMI_cat, 
    family="binomial",
    data=combined.data) -> obesity.glm2

obesity.glm2 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on hypertension, with stress as a modifier", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on hypertension, with stress as a modifier

|term                              | estimate| std.error| statistic|  p.value|
|:---------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                       |    -1.27|     0.210|     -6.03| 1.65e-09|
|BMI_catNormal                     |     0.05|     0.213|      0.25| 8.06e-01|
|BMI_catOverweight                 |     0.67|     0.212|      3.17| 1.51e-03|
|BMI_catClass I Obese              |     1.13|     0.212|      5.34| 9.33e-08|
|BMI_catClass II Obese             |     1.32|     0.214|      6.18| 6.23e-10|
|BMI_catClass III Obese            |     1.46|     0.216|      6.75| 1.46e-11|
|StressHigh                        |     0.19|     0.282|      0.66| 5.08e-01|
|BMI_catNormal:StressHigh          |    -0.09|     0.286|     -0.33| 7.45e-01|
|BMI_catOverweight:StressHigh      |    -0.16|     0.284|     -0.55| 5.84e-01|
|BMI_catClass I Obese:StressHigh   |    -0.19|     0.285|     -0.67| 5.04e-01|
|BMI_catClass II Obese:StressHigh  |    -0.18|     0.288|     -0.63| 5.30e-01|
|BMI_catClass III Obese:StressHigh |    -0.21|     0.290|     -0.72| 4.72e-01|

```r
anova(obesity.glm2,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier

|term           | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:--------------|--:|--------:|---------:|----------:|-------:|
|NULL           | NA|       NA|     39555|      52730|      NA|
|BMI_cat        |  5|     1942|     39550|      50788|   0.000|
|Stress         |  1|        2|     39549|      50787|   0.212|
|BMI_cat:Stress |  5|        3|     39544|      50783|   0.645|

```r
#adding in age and gender as covariates as a modifier
glm(HypertensionAny~BMI_cat+Stress+Stress:BMI_cat+Gender+age, 
    family="binomial",
    data=combined.data) -> obesity.glm3

obesity.glm3 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on hypertension, with stress as a modifier and age and  gender as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on hypertension, with stress as a modifier and age and  gender as covarites

|term                              | estimate| std.error| statistic|  p.value|
|:---------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                       |    -4.50|     0.234|    -19.22| 2.53e-82|
|BMI_catNormal                     |    -0.07|     0.232|     -0.29| 7.70e-01|
|BMI_catOverweight                 |     0.33|     0.231|      1.41| 1.57e-01|
|BMI_catClass I Obese              |     0.87|     0.231|      3.76| 1.67e-04|
|BMI_catClass II Obese             |     1.21|     0.233|      5.20| 1.97e-07|
|BMI_catClass III Obese            |     1.59|     0.235|      6.77| 1.30e-11|
|StressHigh                        |     0.30|     0.307|      0.97| 3.31e-01|
|GenderM                           |     0.30|     0.024|     12.97| 1.83e-38|
|age                               |     0.06|     0.001|     69.39| 0.00e+00|
|BMI_catNormal:StressHigh          |    -0.09|     0.312|     -0.28| 7.79e-01|
|BMI_catOverweight:StressHigh      |    -0.11|     0.310|     -0.35| 7.26e-01|
|BMI_catClass I Obese:StressHigh   |    -0.17|     0.311|     -0.55| 5.86e-01|
|BMI_catClass II Obese:StressHigh  |    -0.16|     0.314|     -0.50| 6.16e-01|
|BMI_catClass III Obese:StressHigh |    -0.19|     0.316|     -0.59| 5.58e-01|

```r
anova(obesity.glm3,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on hypertension, with stress as a modifier and age and gender as covarite", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on hypertension, with stress as a modifier and age and gender as covarite

|term           | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:--------------|--:|--------:|---------:|----------:|-------:|
|NULL           | NA|       NA|     39555|      52730|      NA|
|BMI_cat        |  5|     1942|     39550|      50788|   0.000|
|Stress         |  1|        2|     39549|      50787|   0.212|
|Gender         |  1|      459|     39548|      50328|   0.000|
|age            |  1|     6064|     39547|      44264|   0.000|
|BMI_cat:Stress |  5|        3|     39542|      44261|   0.774|

```r
#adding in race and ethnicity
glm(HypertensionAny~BMI_cat+Stress+Stress:BMI_cat+Gender+age+Race.Ethnicity, 
    family="binomial",
    data=combined.data) -> obesity.glm4

obesity.glm4 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on hypertension, with stress as a modifier and age, gender and race as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on hypertension, with stress as a modifier and age, gender and race as covarites

|term                              | estimate| std.error| statistic|  p.value|
|:---------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                       |    -4.33|     0.255|    -16.98| 1.24e-64|
|BMI_catNormal                     |    -0.07|     0.232|     -0.32| 7.47e-01|
|BMI_catOverweight                 |     0.32|     0.231|      1.37| 1.71e-01|
|BMI_catClass I Obese              |     0.86|     0.231|      3.70| 2.14e-04|
|BMI_catClass II Obese             |     1.20|     0.233|      5.15| 2.64e-07|
|BMI_catClass III Obese            |     1.57|     0.235|      6.66| 2.71e-11|
|StressHigh                        |     0.30|     0.308|      0.97| 3.32e-01|
|GenderM                           |     0.31|     0.024|     13.21| 7.40e-40|
|age                               |     0.06|     0.001|     69.48| 0.00e+00|
|Race.EthnicityBlack               |     0.44|     0.121|      3.63| 2.83e-04|
|Race.EthnicityHispanic/Latino     |    -0.44|     0.142|     -3.09| 2.01e-03|
|Race.EthnicityOther               |    -0.45|     0.128|     -3.50| 4.65e-04|
|Race.EthnicityWhite               |    -0.24|     0.110|     -2.15| 3.12e-02|
|BMI_catNormal:StressHigh          |    -0.09|     0.313|     -0.28| 7.76e-01|
|BMI_catOverweight:StressHigh      |    -0.11|     0.311|     -0.37| 7.13e-01|
|BMI_catClass I Obese:StressHigh   |    -0.17|     0.311|     -0.56| 5.77e-01|
|BMI_catClass II Obese:StressHigh  |    -0.17|     0.315|     -0.53| 5.95e-01|
|BMI_catClass III Obese:StressHigh |    -0.19|     0.317|     -0.59| 5.53e-01|

```r
anova(obesity.glm4,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on hypertension, with stress as a modifier and age, gender and race as covarite", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on hypertension, with stress as a modifier and age, gender and race as covarite

|term           | df| Deviance| Resid..Df| Resid..Dev|  p.value|
|:--------------|--:|--------:|---------:|----------:|--------:|
|NULL           | NA|       NA|     39555|      52730|       NA|
|BMI_cat        |  5|     1942|     39550|      50788| 0.00e+00|
|Stress         |  1|        2|     39549|      50787| 2.12e-01|
|Gender         |  1|      459|     39548|      50328| 0.00e+00|
|age            |  1|     6064|     39547|      44264| 0.00e+00|
|Race.Ethnicity |  4|      171|     39543|      44092| 5.31e-36|
|BMI_cat:Stress |  5|        3|     39538|      44090| 7.61e-01|

### Hypertension Rates by Quartiles


```r
with(combined.data, table(HypertensionAny,BMI_cat.obese,Stress.quartile,Gender)) %>% 
  data.frame %>%
  pivot_wider(names_from=HypertensionAny,
              values_from = Freq) %>%
  rename(HypertensionAny=`1`,
         NonDisease=`0`) %>%
  mutate(Total=HypertensionAny+NonDisease) %>%
  mutate(Percent=HypertensionAny/Total*100) -> hypertension.bmi.stress.quartile.counts

kable(hypertension.bmi.stress.quartile.counts, caption="Hypertension Rates by BMI and Stress Quartile")
```



Table: Hypertension Rates by BMI and Stress Quartile

|BMI_cat.obese |Stress.quartile |Gender | NonDisease| HypertensionAny| Total| Percent|
|:-------------|:---------------|:------|----------:|---------------:|-----:|-------:|
|Underweight   |(-0.016,4]      |F      |         54|              19|    73|    26.0|
|Normal        |(-0.016,4]      |F      |       2306|             565|  2871|    19.7|
|Overweight    |(-0.016,4]      |F      |       1965|             820|  2785|    29.4|
|Obese         |(-0.016,4]      |F      |       2168|            1711|  3879|    44.1|
|Underweight   |(12,16]         |F      |          2|               1|     3|    33.3|
|Normal        |(12,16]         |F      |         62|              15|    77|    19.5|
|Overweight    |(12,16]         |F      |         56|              25|    81|    30.9|
|Obese         |(12,16]         |F      |         85|              62|   147|    42.2|
|Underweight   |(4,8]           |F      |         65|              18|    83|    21.7|
|Normal        |(4,8]           |F      |       1757|             473|  2230|    21.2|
|Overweight    |(4,8]           |F      |       1547|             696|  2243|    31.0|
|Obese         |(4,8]           |F      |       2016|            1606|  3622|    44.3|
|Underweight   |(8,12]          |F      |         25|               7|    32|    21.9|
|Normal        |(8,12]          |F      |        513|             144|   657|    21.9|
|Overweight    |(8,12]          |F      |        461|             220|   681|    32.3|
|Obese         |(8,12]          |F      |        713|             590|  1303|    45.3|
|Underweight   |(-0.016,4]      |M      |         22|               6|    28|    21.4|
|Normal        |(-0.016,4]      |M      |       1425|             542|  1967|    27.6|
|Overweight    |(-0.016,4]      |M      |       2272|            1518|  3790|    40.1|
|Obese         |(-0.016,4]      |M      |       1724|            2145|  3869|    55.4|
|Underweight   |(12,16]         |M      |          2|               0|     2|     0.0|
|Normal        |(12,16]         |M      |         31|              17|    48|    35.4|
|Overweight    |(12,16]         |M      |         31|              21|    52|    40.4|
|Obese         |(12,16]         |M      |         49|              41|    90|    45.6|
|Underweight   |(4,8]           |M      |         34|              12|    46|    26.1|
|Normal        |(4,8]           |M      |       1018|             417|  1435|    29.1|
|Overweight    |(4,8]           |M      |       1599|            1080|  2679|    40.3|
|Obese         |(4,8]           |M      |       1328|            1679|  3007|    55.8|
|Underweight   |(8,12]          |M      |         11|               4|    15|    26.7|
|Normal        |(8,12]          |M      |        267|             102|   369|    27.6|
|Overweight    |(8,12]          |M      |        345|             236|   581|    40.6|
|Obese         |(8,12]          |M      |        368|             443|   811|    54.6|

```r
ggplot(hypertension.bmi.stress.quartile.counts,
       aes(y=Percent,
           x=BMI_cat.obese,
           fill=Stress.quartile)) +
  geom_bar(stat='identity',position='dodge') +
  labs(y="Percent HypertensionAny",
       title="Effects of Chronic Stress on Hypertension",
       x="") +
  theme_classic() +
  facet_grid(.~Gender) +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.15,0.75))
```

![](figures/hypertension-BMI-stress-quartile-1.png)<!-- -->

## Hypertension Rates by Normal Obesity and Stress


```r
#calculating hypertension rates by bmi category, stress and gender
with(combined.data, table(HypertensionAny,BMI_cat.obese,Stress,Gender)) %>% 
  data.frame %>%
  pivot_wider(names_from=HypertensionAny,
              values_from = Freq) %>%
  rename(HypertensionAny=`1`,
         NonDisease=`0`) %>%
  mutate(Total=HypertensionAny+NonDisease) %>%
  mutate(Percent=HypertensionAny/Total*100) -> hypertension.bmi.stress.gender.counts

kable(hypertension.bmi.stress.gender.counts, caption="Hypertension Rates by BMI and Stress")
```



Table: Hypertension Rates by BMI and Stress

|BMI_cat.obese |Stress |Gender | NonDisease| HypertensionAny| Total| Percent|
|:-------------|:------|:------|----------:|---------------:|-----:|-------:|
|Underweight   |Low    |F      |         71|              22|    93|    23.7|
|Normal        |Low    |F      |       2759|             672|  3431|    19.6|
|Overweight    |Low    |F      |       2352|             974|  3326|    29.3|
|Obese         |Low    |F      |       2617|            2063|  4680|    44.1|
|Underweight   |High   |F      |         75|              23|    98|    23.5|
|Normal        |High   |F      |       1879|             525|  2404|    21.8|
|Overweight    |High   |F      |       1677|             787|  2464|    31.9|
|Obese         |High   |F      |       2365|            1906|  4271|    44.6|
|Underweight   |Low    |M      |         32|               7|    39|    17.9|
|Normal        |Low    |M      |       1654|             637|  2291|    27.8|
|Overweight    |Low    |M      |       2634|            1773|  4407|    40.2|
|Obese         |Low    |M      |       2051|            2498|  4549|    54.9|
|Underweight   |High   |M      |         37|              15|    52|    28.8|
|Normal        |High   |M      |       1087|             441|  1528|    28.9|
|Overweight    |High   |M      |       1613|            1082|  2695|    40.1|
|Obese         |High   |M      |       1418|            1810|  3228|    56.1|

```r
ggplot(hypertension.bmi.stress.gender.counts,
       aes(y=Percent,
           x=BMI_cat.obese,
           fill=Stress)) +
  geom_bar(stat='identity',position='dodge') +
  labs(y="Percent Hypertension",
       title="Effects of Chronic Stress on Hypertension",
       x="") +
  facet_grid(.~Gender) +
  theme_classic() +
  scale_fill_grey() +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.75))
```

![](figures/hypertension-BMI-obese-1.png)<!-- -->

## Logistic Regressions for Obese/Non-Obese

Ran a series of logistic regressions using the normal obesity categories not classes as the categorization


```r
glm(HypertensionAny~BMI_cat.obese, 
    family="binomial",
    data=combined.data) -> obesity.glm1

obesity.glm1 %>%
  tidy() %>%
  kable(caption="Logistic regression of obese vs non-obese on liver disease", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obese vs non-obese on liver disease

|term                    | estimate| std.error| statistic|  p.value|
|:-----------------------|--------:|---------:|---------:|--------:|
|(Intercept)             |    -1.17|     0.140|     -8.33| 7.87e-17|
|BMI_cat.obeseNormal     |    -0.01|     0.142|     -0.08| 9.40e-01|
|BMI_cat.obeseOverweight |     0.58|     0.141|      4.13| 3.71e-05|
|BMI_cat.obeseObese      |     1.15|     0.141|      8.13| 4.12e-16|

```r
anova(obesity.glm1,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on liver disease, ", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on liver disease, 

|term          | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:-------------|--:|--------:|---------:|----------:|-------:|
|NULL          | NA|       NA|     39555|      52730|      NA|
|BMI_cat.obese |  3|     1872|     39552|      50858|       0|

```r
#adding in stress as a modifier
glm(HypertensionAny~BMI_cat.obese+Stress+Stress:BMI_cat.obese, 
    family="binomial",
    data=combined.data) -> obesity.glm2

obesity.glm2 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on liver disease, with stress as a modifier", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on liver disease, with stress as a modifier

|term                               | estimate| std.error| statistic|  p.value|
|:----------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                        |    -1.27|     0.210|     -6.03| 1.65e-09|
|BMI_cat.obeseNormal                |     0.05|     0.213|      0.25| 8.06e-01|
|BMI_cat.obeseOverweight            |     0.67|     0.212|      3.17| 1.51e-03|
|BMI_cat.obeseObese                 |     1.24|     0.211|      5.89| 3.86e-09|
|StressHigh                         |     0.19|     0.282|      0.66| 5.08e-01|
|BMI_cat.obeseNormal:StressHigh     |    -0.09|     0.286|     -0.33| 7.45e-01|
|BMI_cat.obeseOverweight:StressHigh |    -0.16|     0.284|     -0.55| 5.84e-01|
|BMI_cat.obeseObese:StressHigh      |    -0.18|     0.284|     -0.64| 5.23e-01|

```r
anova(obesity.glm2,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on liver disease, with stress as a modifier", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on liver disease, with stress as a modifier

|term                 | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:--------------------|--:|--------:|---------:|----------:|-------:|
|NULL                 | NA|       NA|     39555|      52730|      NA|
|BMI_cat.obese        |  3|     1872|     39552|      50858|   0.000|
|Stress               |  1|        2|     39551|      50856|   0.139|
|BMI_cat.obese:Stress |  3|        3|     39548|      50854|   0.451|

```r
#adding in age and gender as covariates as a modifier
glm(HypertensionAny~BMI_cat.obese+Stress+Stress:BMI_cat.obese+Gender+age, 
    family="binomial",
    data=combined.data) -> obesity.glm3

obesity.glm3 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on liver disease, with stress as a modifier and age and  gender as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on liver disease, with stress as a modifier and age and  gender as covarites

|term                               | estimate| std.error| statistic|  p.value|
|:----------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                        |    -4.42|     0.233|    -18.93| 6.54e-80|
|BMI_cat.obeseNormal                |    -0.06|     0.231|     -0.26| 7.97e-01|
|BMI_cat.obeseOverweight            |     0.34|     0.230|      1.49| 1.37e-01|
|BMI_cat.obeseObese                 |     1.10|     0.229|      4.81| 1.49e-06|
|StressHigh                         |     0.30|     0.307|      0.97| 3.30e-01|
|GenderM                            |     0.26|     0.023|     11.32| 1.03e-29|
|age                                |     0.06|     0.001|     68.75| 0.00e+00|
|BMI_cat.obeseNormal:StressHigh     |    -0.09|     0.311|     -0.29| 7.71e-01|
|BMI_cat.obeseOverweight:StressHigh |    -0.11|     0.309|     -0.37| 7.13e-01|
|BMI_cat.obeseObese:StressHigh      |    -0.15|     0.308|     -0.49| 6.23e-01|

```r
anova(obesity.glm3,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on liver disease, with stress as a modifier and age and gender as covarite", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on liver disease, with stress as a modifier and age and gender as covarite

|term                 | df| Deviance| Resid..Df| Resid..Dev|  p.value|
|:--------------------|--:|--------:|---------:|----------:|--------:|
|NULL                 | NA|       NA|     39555|      52730|       NA|
|BMI_cat.obese        |  3|     1872|     39552|      50858| 0.00e+00|
|Stress               |  1|        2|     39551|      50856| 1.39e-01|
|Gender               |  1|      415|     39550|      50442| 3.61e-92|
|age                  |  1|     5904|     39549|      44537| 0.00e+00|
|BMI_cat.obese:Stress |  3|        1|     39546|      44536| 7.33e-01|

```r
#adding in race and ethnicity
glm(HypertensionAny~BMI_cat.obese+Stress+Stress:BMI_cat.obese+Gender+age+Race.Ethnicity, 
    family="binomial",
    data=combined.data) -> obesity.glm4

obesity.glm4 %>%
  tidy() %>%
  kable(caption="Logistic regression of obesity on liver diesease, with stress as a modifier and age, gender and race as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obesity on liver diesease, with stress as a modifier and age, gender and race as covarites

|term                               | estimate| std.error| statistic|  p.value|
|:----------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                        |    -4.29|     0.254|    -16.85| 1.11e-63|
|BMI_cat.obeseNormal                |    -0.07|     0.231|     -0.29| 7.70e-01|
|BMI_cat.obeseOverweight            |     0.33|     0.230|      1.43| 1.51e-01|
|BMI_cat.obeseObese                 |     1.09|     0.230|      4.73| 2.21e-06|
|StressHigh                         |     0.30|     0.307|      0.97| 3.33e-01|
|GenderM                            |     0.27|     0.023|     11.61| 3.74e-31|
|age                                |     0.06|     0.001|     68.86| 0.00e+00|
|Race.EthnicityBlack                |     0.50|     0.121|      4.10| 4.08e-05|
|Race.EthnicityHispanic/Latino      |    -0.41|     0.142|     -2.88| 3.97e-03|
|Race.EthnicityOther                |    -0.41|     0.128|     -3.17| 1.50e-03|
|Race.EthnicityWhite                |    -0.20|     0.109|     -1.80| 7.15e-02|
|BMI_cat.obeseNormal:StressHigh     |    -0.09|     0.312|     -0.29| 7.68e-01|
|BMI_cat.obeseOverweight:StressHigh |    -0.12|     0.310|     -0.38| 7.02e-01|
|BMI_cat.obeseObese:StressHigh      |    -0.16|     0.309|     -0.51| 6.13e-01|

```r
anova(obesity.glm4,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obesity on liver disease, with stress as a modifier and age, gender and race as covariates", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obesity on liver disease, with stress as a modifier and age, gender and race as covariates

|term                 | df| Deviance| Resid..Df| Resid..Dev|  p.value|
|:--------------------|--:|--------:|---------:|----------:|--------:|
|NULL                 | NA|       NA|     39555|      52730|       NA|
|BMI_cat.obese        |  3|     1872|     39552|      50858| 0.00e+00|
|Stress               |  1|        2|     39551|      50856| 1.39e-01|
|Gender               |  1|      415|     39550|      50442| 3.61e-92|
|age                  |  1|     5904|     39549|      44537| 0.00e+00|
|Race.Ethnicity       |  4|      180|     39545|      44358| 9.51e-38|
|BMI_cat.obese:Stress |  3|        1|     39542|      44356| 7.09e-01|

# Hypertension Rates by Obese/Not Obese and Stress


```r
with(combined.data, table(HypertensionAny,BMI_cat.Ob.NonOb,Stress,Gender)) %>% 
  data.frame %>%
  pivot_wider(names_from=HypertensionAny,
              values_from = Freq) %>%
  rename(HypertensionAny=`1`,
         NonDisease=`0`) %>%
  mutate(Total=HypertensionAny+NonDisease) %>%
  mutate(Percent=HypertensionAny/Total*100) -> hypertension.BMI_cat.Ob.NonOb.stress.counts

kable(hypertension.BMI_cat.Ob.NonOb.stress.counts, caption="Hypertension Rates by Obese or not and Stress")
```



Table: Hypertension Rates by Obese or not and Stress

|BMI_cat.Ob.NonOb |Stress |Gender | NonDisease| HypertensionAny| Total| Percent|
|:----------------|:------|:------|----------:|---------------:|-----:|-------:|
|Non-Obese        |Low    |F      |       5225|            1681|  6906|    24.3|
|Obese            |Low    |F      |       2617|            2063|  4680|    44.1|
|Non-Obese        |High   |F      |       3660|            1346|  5006|    26.9|
|Obese            |High   |F      |       2365|            1906|  4271|    44.6|
|Non-Obese        |Low    |M      |       4335|            2421|  6756|    35.8|
|Obese            |Low    |M      |       2051|            2498|  4549|    54.9|
|Non-Obese        |High   |M      |       2750|            1545|  4295|    36.0|
|Obese            |High   |M      |       1418|            1810|  3228|    56.1|

```r
ggplot(hypertension.BMI_cat.Ob.NonOb.stress.counts,
       aes(y=Percent,
           x=BMI_cat.Ob.NonOb,
           fill=Stress)) +
  geom_bar(stat='identity',position='dodge') +
  labs(y="Percent Hypertension",
       title="Effects of Chronic Stress on Hypertension",
       x="") +
  facet_grid(.~Gender) +
  theme_classic() +
  scale_fill_grey() +
  theme(text=element_text(size=16),
        axis.text.x=element_text(angle=90,vjust=0.5,hjust=1),
        legend.position = c(0.1,0.75))
```

![](figures/hypertension-BMI-obese-nonobese-1.png)<!-- -->

## Logistic Regressions for Obese/Non-Obese

Ran a series of logistic regressions using obese/non-obese as the categorization


```r
glm(HypertensionAny~BMI_cat.Ob.NonOb, 
    family="binomial",
    data=combined.data) -> obesity.glm1

obesity.glm1 %>%
  tidy() %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obese vs non-obese on hypertension

|term                  | estimate| std.error| statistic| p.value|
|:---------------------|--------:|---------:|---------:|-------:|
|(Intercept)           |    -0.83|     0.014|     -57.6|       0|
|BMI_cat.Ob.NonObObese |     0.80|     0.021|      38.2|       0|

```r
anova(obesity.glm1,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, ", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, 

|term             | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:----------------|--:|--------:|---------:|----------:|-------:|
|NULL             | NA|       NA|     39690|      52894|      NA|
|BMI_cat.Ob.NonOb |  1|     1478|     39689|      51417|       0|

```r
#adding in stress as a modifier
glm(HypertensionAny~BMI_cat.Ob.NonOb+Stress+Stress:BMI_cat.Ob.NonOb, 
    family="binomial",
    data=combined.data) -> obesity.glm2

obesity.glm2 %>%
  tidy() %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier

|term                             | estimate| std.error| statistic| p.value|
|:--------------------------------|--------:|---------:|---------:|-------:|
|(Intercept)                      |    -0.85|     0.019|    -45.33|  0.0000|
|BMI_cat.Ob.NonObObese            |     0.82|     0.028|     29.43|  0.0000|
|StressHigh                       |     0.05|     0.029|      1.71|  0.0873|
|BMI_cat.Ob.NonObObese:StressHigh |    -0.04|     0.043|     -1.04|  0.2961|

```r
anova(obesity.glm2,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier

|term                    | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:-----------------------|--:|--------:|---------:|----------:|-------:|
|NULL                    | NA|       NA|     39690|      52894|      NA|
|BMI_cat.Ob.NonOb        |  1|     1478|     39689|      51417|   0.000|
|Stress                  |  1|        2|     39688|      51415|   0.173|
|BMI_cat.Ob.NonOb:Stress |  1|        1|     39687|      51414|   0.296|

```r
#adding in age and gender as covariates as a modifier
glm(HypertensionAny~BMI_cat.Ob.NonOb+Stress+Stress:BMI_cat.Ob.NonOb+Gender+age, 
    family="binomial",
    data=combined.data) -> obesity.glm3

obesity.glm3 %>%
  tidy() %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age and  gender as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age and  gender as covarites

|term                             | estimate| std.error| statistic|  p.value|
|:--------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                      |    -4.26|     0.054|    -79.09| 0.00e+00|
|BMI_cat.Ob.NonObObese            |     0.92|     0.031|     30.02| 0.00e+00|
|StressHigh                       |     0.19|     0.032|      5.95| 2.64e-09|
|GenderM                          |     0.29|     0.023|     12.77| 2.36e-37|
|age                              |     0.06|     0.001|     69.61| 0.00e+00|
|BMI_cat.Ob.NonObObese:StressHigh |    -0.04|     0.046|     -0.88| 3.77e-01|

```r
anova(obesity.glm3,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age and gender as covarite", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age and gender as covarite

|term                    | df| Deviance| Resid..Df| Resid..Dev| p.value|
|:-----------------------|--:|--------:|---------:|----------:|-------:|
|NULL                    | NA|       NA|     39690|      52894|      NA|
|BMI_cat.Ob.NonOb        |  1|     1478|     39689|      51417|   0.000|
|Stress                  |  1|        2|     39688|      51415|   0.173|
|Gender                  |  1|      504|     39687|      50911|   0.000|
|age                     |  1|     6097|     39686|      44814|   0.000|
|BMI_cat.Ob.NonOb:Stress |  1|        1|     39685|      44813|   0.377|

```r
#adding in race and ethnicity
glm(HypertensionAny~BMI_cat.Ob.NonOb+Stress+Stress:BMI_cat.Ob.NonOb+Gender+age+Race.Ethnicity, 
    family="binomial",
    data=combined.data) -> obesity.glm4

obesity.glm4 %>%
  tidy() %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age, gender and race as covarites", digits =c(0,2,3,2,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age, gender and race as covarites

|term                             | estimate| std.error| statistic|  p.value|
|:--------------------------------|--------:|---------:|---------:|--------:|
|(Intercept)                      |    -4.19|     0.116|    -36.11| 0.00e+00|
|BMI_cat.Ob.NonObObese            |     0.91|     0.031|     29.61| 0.00e+00|
|StressHigh                       |     0.19|     0.032|      5.80| 6.80e-09|
|GenderM                          |     0.30|     0.023|     13.02| 8.91e-39|
|age                              |     0.06|     0.001|     69.67| 0.00e+00|
|Race.EthnicityBlack              |     0.56|     0.120|      4.64| 3.46e-06|
|Race.EthnicityHispanic/Latino    |    -0.36|     0.141|     -2.55| 1.06e-02|
|Race.EthnicityOther              |    -0.35|     0.127|     -2.80| 5.14e-03|
|Race.EthnicityWhite              |    -0.15|     0.109|     -1.36| 1.74e-01|
|BMI_cat.Ob.NonObObese:StressHigh |    -0.04|     0.047|     -0.91| 3.63e-01|

```r
anova(obesity.glm4,test="Chisq") %>% tidy %>%
  kable(caption="Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age, gender and race as covarite", digits =c(0,0,0,0,0,99))
```



Table: Logistic regression of obese vs non-obese on hypertension, with stress as a modifier and age, gender and race as covarite

|term                    | df| Deviance| Resid..Df| Resid..Dev|  p.value|
|:-----------------------|--:|--------:|---------:|----------:|--------:|
|NULL                    | NA|       NA|     39690|      52894|       NA|
|BMI_cat.Ob.NonOb        |  1|     1478|     39689|      51417| 0.00e+00|
|Stress                  |  1|        2|     39688|      51415| 1.73e-01|
|Gender                  |  1|      504|     39687|      50911| 0.00e+00|
|age                     |  1|     6097|     39686|      44814| 0.00e+00|
|Race.Ethnicity          |  4|      184|     39682|      44630| 9.56e-39|
|BMI_cat.Ob.NonOb:Stress |  1|        1|     39681|      44629| 3.63e-01|

# Summary of Covariates

Stratified data by stress and obesity status and summarized data


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
  group_by(Stress,BMI_cat.Ob.NonOb,Race.Ethnicity) %>%
  count %>%
    filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  knitr::kable(caption="Number of participants by group and race/ethnicity")
```



Table: Number of participants by group and race/ethnicity

|Stress |BMI_cat.Ob.NonOb |Race.Ethnicity  |     n|
|:------|:----------------|:---------------|-----:|
|Low    |Non-Obese        |Asian           |   316|
|Low    |Non-Obese        |Black           |   393|
|Low    |Non-Obese        |Hispanic/Latino |   250|
|Low    |Non-Obese        |Other           |   431|
|Low    |Non-Obese        |White           | 12272|
|Low    |Obese            |Asian           |    37|
|Low    |Obese            |Black           |   485|
|Low    |Obese            |Hispanic/Latino |   180|
|Low    |Obese            |Other           |   298|
|Low    |Obese            |White           |  8229|
|High   |Non-Obese        |Asian           |   188|
|High   |Non-Obese        |Black           |   385|
|High   |Non-Obese        |Hispanic/Latino |   185|
|High   |Non-Obese        |Other           |   308|
|High   |Non-Obese        |White           |  8235|
|High   |Obese            |Asian           |    43|
|High   |Obese            |Black           |   475|
|High   |Obese            |Hispanic/Latino |   164|
|High   |Obese            |Other           |   231|
|High   |Obese            |White           |  6586|

```r
combined.data %>%
  group_by(Stress,BMI_cat.Ob.NonOb) %>%
    filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  summarize_at(c('BMI','age'), list(mean=~mean(.x,na.rm=T),
                                    sd=~sd(.x,na.rm=T),
                                    n=~length(.x)))%>%
  knitr::kable(caption="Average BMI and age of participants by group")
```



Table: Average BMI and age of participants by group

|Stress |BMI_cat.Ob.NonOb | BMI_mean| age_mean| BMI_sd| age_sd| BMI_n| age_n|
|:------|:----------------|--------:|--------:|------:|------:|-----:|-----:|
|Low    |Non-Obese        |     25.3|     53.0|   2.98|   17.7| 13662| 13662|
|Low    |Obese            |     36.0|     54.7|   5.72|   14.6|  9229|  9229|
|High   |Non-Obese        |     25.1|     51.0|   3.13|   17.8|  9301|  9301|
|High   |Obese            |     36.6|     52.6|   6.00|   14.6|  7499|  7499|

```r
combined.data %>%
  group_by(Stress,BMI_cat.Ob.NonOb) %>%
  summarize_at(c('BMI','age'), list(mean=~mean(.x,na.rm=T),
                                    sd=~sd(.x,na.rm=T),
                                    n=~length(.x)))%>%
  filter(!(is.na(Stress))) %>%
  filter(!(is.na(BMI_cat.Ob.NonOb))) %>%
  knitr::kable(caption="Average BMI and age of participants by group,complete cases")
```



Table: Average BMI and age of participants by group,complete cases

|Stress |BMI_cat.Ob.NonOb | BMI_mean| age_mean| BMI_sd| age_sd| BMI_n| age_n|
|:------|:----------------|--------:|--------:|------:|------:|-----:|-----:|
|Low    |Non-Obese        |     25.3|     53.0|   2.98|   17.7| 13662| 13662|
|Low    |Obese            |     36.0|     54.7|   5.72|   14.6|  9229|  9229|
|High   |Non-Obese        |     25.1|     51.0|   3.13|   17.8|  9301|  9301|
|High   |Obese            |     36.6|     52.6|   6.00|   14.6|  7499|  7499|

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
## [1] broom_1.0.1   ggplot2_3.4.0 tidyr_1.2.1   dplyr_1.0.10  readr_2.1.3  
## [6] knitr_1.41   
## 
## loaded via a namespace (and not attached):
##  [1] highr_0.9        pillar_1.8.1     bslib_0.4.1      compiler_4.2.0  
##  [5] jquerylib_0.1.4  tools_4.2.0      bit_4.0.5        digest_0.6.30   
##  [9] gtable_0.3.1     jsonlite_1.8.4   evaluate_0.18    lifecycle_1.0.3 
## [13] tibble_3.1.8     pkgconfig_2.0.3  rlang_1.0.6      cli_3.4.1       
## [17] DBI_1.1.3        parallel_4.2.0   yaml_2.3.6       xfun_0.35       
## [21] fastmap_1.1.0    withr_2.5.0      stringr_1.5.0    generics_0.1.3  
## [25] vctrs_0.5.1      sass_0.4.4       hms_1.1.2        grid_4.2.0      
## [29] bit64_4.0.5      tidyselect_1.2.0 glue_1.6.2       R6_2.5.1        
## [33] fansi_1.0.3      vroom_1.6.0      rmarkdown_2.18   farver_2.1.1    
## [37] tzdb_0.3.0       purrr_0.3.5      magrittr_2.0.3   backports_1.4.1 
## [41] scales_1.2.1     ellipsis_0.3.2   htmltools_0.5.4  assertthat_0.2.1
## [45] colorspace_2.0-3 labeling_0.4.2   utf8_1.2.2       stringi_1.7.8   
## [49] munsell_0.5.0    cachem_1.0.6     crayon_1.5.2
```
