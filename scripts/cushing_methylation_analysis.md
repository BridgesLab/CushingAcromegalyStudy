Analysis of Methylation Data from Cushing's Study
=============================================================

This file was last compiled on ``Sun Jan 19 08:30:53 2014``.


```
## Loading required package: rJava
## Loading required package: xlsxjars
```


The methylation is in ../data/raw/Summary Table of Cushings Relative Control Methylation Jan 6 2013.xlsx wherea se we used ../data/processed/htseq_Annotated DESeq2 Results - Cushing.csv for the relative expression.

Statics
---------

Tested the predictive value on the delta-beta value on the fold change.


```r
lm.fit.tss1500 <- lm(2^log2FoldChange ~ Delta.Beta.Cushings, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS1500", ])
summary(lm.fit.tss1500)
```

```
## 
## Call:
## lm(formula = 2^log2FoldChange ~ Delta.Beta.Cushings, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS1500", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.5002 -0.1033 -0.0349  0.0940  0.7027 
## 
## Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
## (Intercept)          1.05e+00   3.12e-02   33.56   <2e-16 ***
## Delta.Beta.Cushings -4.07e-05   3.32e-05   -1.23     0.22    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.205 on 119 degrees of freedom
##   (53 observations deleted due to missingness)
## Multiple R-squared:  0.0125,	Adjusted R-squared:  0.00417 
## F-statistic:  1.5 on 1 and 119 DF,  p-value: 0.223
```

```r
par(mfrow = c(2, 2))
plot(lm.fit.tss1500)
```

![plot of chunk statistics](figure/statistics1.png) 

```r
lm.fit.tss200 <- lm(2^log2FoldChange ~ Delta.Beta.Cushings, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS200", ])
summary(lm.fit.tss200)
```

```
## 
## Call:
## lm(formula = 2^log2FoldChange ~ Delta.Beta.Cushings, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS200", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.4881 -0.1419 -0.0344  0.1044  2.3416 
## 
## Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
## (Intercept)          1.09e+00   9.18e-02   11.91   <2e-16 ***
## Delta.Beta.Cushings -9.29e-05   1.02e-04   -0.91     0.37    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.393 on 54 degrees of freedom
##   (26 observations deleted due to missingness)
## Multiple R-squared:  0.0152,	Adjusted R-squared:  -0.00306 
## F-statistic: 0.832 on 1 and 54 DF,  p-value: 0.366
```

```r
plot(lm.fit.tss200)
```

![plot of chunk statistics](figure/statistics2.png) 


Are Differentially Methylated Genes More Likely to Be Differentially Expressed?
---------------------------------------------------------------------------------

To test this, we asked whether the genes with a significantly different methylation pattern had a significantly different expression pattern.  We then compared this to a randomly sampled set of genes from the same expression set.  We then repeated this analysis 1000 times for each of the hypo and hyper expressed genes, and tested how often the chis-quared test led to a significant result.


```
## 
## FALSE  TRUE 
##   678   322
```

```
## 
## FALSE 
##  1000
```


Figures
----------

![plot of chunk figures](figure/figures1.png) ![plot of chunk figures](figure/figures2.png) ![plot of chunk figures](figure/figures3.png) 

Session Information
-------------------

```r
sessionInfo()
```

```
## R version 3.0.2 (2013-09-25)
## Platform: x86_64-apple-darwin10.8.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] xlsx_0.5.5     xlsxjars_0.5.0 rJava_0.9-6    knitr_1.5     
## 
## loaded via a namespace (and not attached):
## [1] evaluate_0.5.1 formatR_0.10   stringr_0.6.2  tools_3.0.2
```

