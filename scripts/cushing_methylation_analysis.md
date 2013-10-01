Analysis of Methylation Data from Cushing's Study
=============================================================

This file was last compiled on ``Tue Oct  1 09:39:04 2013``.




The methylation is in ../data/raw/Cushings GC Analysis.csv wherea se we used ../data/processed/Annotated DESeq Results - Cushing.csv for the relative expression.

Statics
---------

Tested the predictive value on the delta-beta value on the fold change.


```r
lm.fit.tss1500 <- lm(foldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS1500", ])
summary(lm.fit.tss1500)
```

```
## 
## Call:
## lm(formula = foldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS1500", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.5398 -0.1188 -0.0495  0.0585  1.0275 
## 
## Coefficients:
##                     Estimate Std. Error t value Pr(>|t|)    
## (Intercept)           1.0400     0.0140   74.46   <2e-16 ***
## Cushings.Delta.Beta   0.1481     0.0506    2.93   0.0037 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.245 on 305 degrees of freedom
##   (37 observations deleted due to missingness)
## Multiple R-squared:  0.0274,	Adjusted R-squared:  0.0242 
## F-statistic: 8.58 on 1 and 305 DF,  p-value: 0.00366
```

```r
par(mfrow = c(2, 2))
plot(lm.fit.tss1500)
```

![plot of chunk statistics](figure/statistics1.png) 

```r
lm.fit.tss200 <- lm(foldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS200", ])
summary(lm.fit.tss200)
```

```
## 
## Call:
## lm(formula = foldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS200", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.4836 -0.0678 -0.0664  0.0846  0.6145 
## 
## Coefficients:
##                     Estimate Std. Error t value Pr(>|t|)    
## (Intercept)           1.0088     0.0187   53.90  < 2e-16 ***
## Cushings.Delta.Beta  -0.3802     0.0628   -6.06  1.5e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.184 on 127 degrees of freedom
##   (13 observations deleted due to missingness)
## Multiple R-squared:  0.224,	Adjusted R-squared:  0.218 
## F-statistic: 36.7 on 1 and 127 DF,  p-value: 1.46e-08
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
##   793   207
```

```
## 
## FALSE  TRUE 
##   895   105
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
## R version 3.0.1 (2013-05-16)
## Platform: x86_64-apple-darwin10.8.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] knitr_1.4
## 
## loaded via a namespace (and not attached):
## [1] digest_0.6.3   evaluate_0.4.7 formatR_0.9    stringr_0.6.2 
## [5] tools_3.0.1
```

