Analysis of Methylation Data from Cushing's Study
=============================================================

This file was last compiled on ``Sun Jan 19 07:59:55 2014``.




The methylation is in ../data/raw/Cushings GC Analysis.csv wherea se we used ../data/processed/htseq_Annotated DESeq2 Results - Cushing.csv for the relative expression.  There was 

Statics
---------

Tested the predictive value on the delta-beta value on the fold change.


```r
lm.fit.tss1500 <- lm(log2FoldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS1500", ])
summary(lm.fit.tss1500)
```

```
## 
## Call:
## lm(formula = log2FoldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS1500", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.7058 -0.1737 -0.0168  0.1156  0.6646 
## 
## Coefficients:
##                     Estimate Std. Error t value Pr(>|t|)
## (Intercept)           0.0709     0.0473    1.50     0.14
## Cushings.Delta.Beta  -0.1692     0.1668   -1.01     0.32
## 
## Residual standard error: 0.304 on 40 degrees of freedom
##   (41 observations deleted due to missingness)
## Multiple R-squared:  0.0251,	Adjusted R-squared:  0.000719 
## F-statistic: 1.03 on 1 and 40 DF,  p-value: 0.316
```

```r
par(mfrow = c(2, 2))
plot(lm.fit.tss1500)
```

![plot of chunk statistics](figure/statistics1.png) 

```r
lm.fit.tss200 <- lm(log2FoldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
    "TSS200", ])
summary(lm.fit.tss200)
```

```
## 
## Call:
## lm(formula = log2FoldChange ~ Cushings.Delta.Beta, data = combined.data[combined.data$UCSC_REFGENE_GROUP == 
##     "TSS200", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -0.7845 -0.1172  0.0696  0.1963  0.5675 
## 
## Coefficients:
##                     Estimate Std. Error t value Pr(>|t|)
## (Intercept)          -0.0604     0.0588   -1.03     0.32
## Cushings.Delta.Beta   0.2523     0.2108    1.20     0.24
## 
## Residual standard error: 0.284 on 22 degrees of freedom
##   (22 observations deleted due to missingness)
## Multiple R-squared:  0.0611,	Adjusted R-squared:  0.0185 
## F-statistic: 1.43 on 1 and 22 DF,  p-value: 0.244
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
##   875   125
```

```
## 
## FALSE  TRUE 
##   790   210
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
## [1] knitr_1.5
## 
## loaded via a namespace (and not attached):
## [1] evaluate_0.5.1 formatR_0.10   stringr_0.6.2  tools_3.0.2
```

