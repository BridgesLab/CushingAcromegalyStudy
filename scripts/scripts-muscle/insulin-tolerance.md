---
title: "Insulin Tolerance Tests Controlling for Lean Mass"
author: "Laura Gunder and Dave Bridges"
date: "March 23, 2019"
output:
  html_document:
    highlight: tango
    keep_md: yes
    number_sections: no
    toc: yes
  pdf_document:
    highlight: tango
    keep_tex: yes
    number_sections: no
    toc: yes
---








# Insulin Tolerance Test

## Raw Values

![](figures/itt-raw-1.png)<!-- -->

## Normalized Values
  
![](figures/itt-normalized-1.png)<!-- -->
    
 
# Fasting Blood Glucose

![](figures/fasting-blood-glucose-1.png)<!-- -->

Table: ANOVA of FBG

term               df    sumsq   meansq   statistic   p.value
---------------  ----  -------  -------  ----------  --------
diet                1   148455   148455        29.4         0
treatment           1   363930   363930        72.1         0
diet:treatment      1    99594    99594        19.7         0
Residuals         131   661587     5050          NA        NA


```
## 
## 	Shapiro-Wilk normality test
## 
## data:  .
## W = 1, p-value = 0.2
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  .
## W = 0.9, p-value = 0.07
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  .
## W = 0.8, p-value = 6e-07
```

```
## 
## 	Wilcoxon rank sum test with continuity correction
## 
## data:  glucose by diet
## W = 2000, p-value = 0.001
## alternative hypothesis: true location shift is not equal to 0
```

```
## [1] 0.0000125
```



Table: ANOVA

term                df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-----------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme    11   650   675     -314        628          NA       NA        NA
glucose.diet.lme    20   641   687     -301        601        26.9        9     0.001



Table: Chi squared test for effects of dexamethasone on NCD for absolute values

term                df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-----------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme    11   683   708     -330        661          NA       NA        NA
glucose.trt.lme     20   630   675     -295        590        71.2        9         0



Table: Chi squared test for effects of dexamethasone on HFD for absolute values

term                df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-----------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme    11   700   723     -339        678          NA       NA        NA
glucose.trt.lme     20   672   715     -316        632        45.4        9         0



Table: Chi squared test for effects of dexamethasone on NCD for normalized values

term                df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-----------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme    11   683   708     -330        661          NA       NA        NA
glucose.trt.lme     20   630   675     -295        590        71.2        9         0



Table: Chi squared test for effects of dexamethasone on HFD for normalized values

term                df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-----------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme    11   700   723     -339        678          NA       NA        NA
glucose.trt.lme     20   672   715     -316        632        45.4        9         0

```
## [1] 15
```



Table: ANOVA for normalized data

term                  df   AIC   BIC   logLik   deviance   statistic   Chi.Df   p.value
-------------------  ---  ----  ----  -------  ---------  ----------  -------  --------
glucose.null.lme.n    11   572   597     -275        550          NA       NA        NA
glucose.diet.lme.n    20   576   621     -268        536        13.6        9     0.136

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  .
## W = 0.9, p-value = 0.5
```

```
## 
## 	Shapiro-Wilk normality test
## 
## data:  .
## W = 0.7, p-value = 0.002
```

```
## [1] 0.0000125
```
