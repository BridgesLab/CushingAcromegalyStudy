Analysis of Clinical Data for Acromegaly Patients
=============================================================

This file was last compiled on ``Sun Mar  2 08:48:08 2014``.  Unless otherwise noted this analysis removes subject 29.

Statistics
-------------




This analysis included 11 controls and 9 acromegaly patients. 


```
## Error: object '..' not found
```


First we checked whether the data was normally distributed using a Shapiro-Wilk test.  If a Shapiro-Wilk Normality test had a p-value <0.05 for a measurement in either the control or the acromegaly cases, we did a Wilcoxon test. This was appropriate for Cer.C14, Cer.C16, Cer.C20, Glu.Cer.C16, insulin, HOMA.IR, glycerol.ins.iso.iso.

We next tested, for the normally distributed data, whether the data had unequal variance.  This was done using Levene's test in the car package <a href="http://socserv.socsci.mcmaster.ca/jfox/Books/Companion">Fox & Weisberg (2011)</a>.  A Welch's t-test for unequal variance was appropriate for glycerol.no.tx based on p<0.05.  In all other cases, a t-test, presuming equal variance was used.



```
## Warning: cannot compute exact p-value with ties
```


<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Mar  2 08:48:10 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> measurement </TH> <TH> Control_mean </TH> <TH> Control_se </TH> <TH> Acromegaly_mean </TH> <TH> Acromegaly_se </TH> <TH> pval </TH> <TH> padj </TH>  </TR>
  <TR> <TD align="right"> 28 </TD> <TD> HOMA.IR </TD> <TD align="right"> 2.0 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 7.6 </TD> <TD align="right"> 3.1 </TD> <TD align="right"> 0.00137 </TD> <TD align="right"> 0.04251 </TD> </TR>
  <TR> <TD align="right"> 2 </TD> <TD> age </TD> <TD align="right"> 63.4 </TD> <TD align="right"> 2.7 </TD> <TD align="right"> 48.3 </TD> <TD align="right"> 4.9 </TD> <TD align="right"> 0.01072 </TD> <TD align="right"> 0.10354 </TD> </TR>
  <TR> <TD align="right"> 29 </TD> <TD> insulin </TD> <TD align="right"> 8.7 </TD> <TD align="right"> 0.9 </TD> <TD align="right"> 25.7 </TD> <TD align="right"> 8.7 </TD> <TD align="right"> 0.01276 </TD> <TD align="right"> 0.10354 </TD> </TR>
  <TR> <TD align="right"> 19 </TD> <TD> glucose </TD> <TD align="right"> 92.5 </TD> <TD align="right"> 2.0 </TD> <TD align="right"> 107.0 </TD> <TD align="right"> 5.4 </TD> <TD align="right"> 0.01336 </TD> <TD align="right"> 0.10354 </TD> </TR>
  <TR> <TD align="right"> 3 </TD> <TD> alk.phos </TD> <TD align="right"> 68.3 </TD> <TD align="right"> 5.5 </TD> <TD align="right"> 95.8 </TD> <TD align="right"> 9.4 </TD> <TD align="right"> 0.01949 </TD> <TD align="right"> 0.12083 </TD> </TR>
  <TR> <TD align="right"> 27 </TD> <TD> height </TD> <TD align="right"> 170.0 </TD> <TD align="right"> 2.4 </TD> <TD align="right"> 180.1 </TD> <TD align="right"> 4.0 </TD> <TD align="right"> 0.03625 </TD> <TD align="right"> 0.14779 </TD> </TR>
  <TR> <TD align="right"> 23 </TD> <TD> glycerol.insulin.2.nM </TD> <TD align="right"> 5.7 </TD> <TD align="right"> 1.2 </TD> <TD align="right"> 11.5 </TD> <TD align="right"> 2.5 </TD> <TD align="right"> 0.03738 </TD> <TD align="right"> 0.14779 </TD> </TR>
  <TR> <TD align="right"> 13 </TD> <TD> Cer.C24 </TD> <TD align="right"> 4.3 </TD> <TD align="right"> 0.6 </TD> <TD align="right"> 6.7 </TD> <TD align="right"> 1.0 </TD> <TD align="right"> 0.03814 </TD> <TD align="right"> 0.14779 </TD> </TR>
  <TR> <TD align="right"> 21 </TD> <TD> glycerol.ins.iso </TD> <TD align="right"> 6.8 </TD> <TD align="right"> 1.5 </TD> <TD align="right"> 17.9 </TD> <TD align="right"> 6.2 </TD> <TD align="right"> 0.05554 </TD> <TD align="right"> 0.18123 </TD> </TR>
  <TR> <TD align="right"> 24 </TD> <TD> glycerol.iso.30.nM </TD> <TD align="right"> 7.6 </TD> <TD align="right"> 1.6 </TD> <TD align="right"> 20.7 </TD> <TD align="right"> 7.5 </TD> <TD align="right"> 0.05846 </TD> <TD align="right"> 0.18123 </TD> </TR>
  <TR> <TD align="right"> 8 </TD> <TD> Cer.C16 </TD> <TD align="right"> 3.4 </TD> <TD align="right"> 0.4 </TD> <TD align="right"> 4.4 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.06926 </TD> <TD align="right"> 0.19518 </TD> </TR>
  <TR> <TD align="right"> 7 </TD> <TD> Cer.C14 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.08534 </TD> <TD align="right"> 0.22047 </TD> </TR>
  <TR> <TD align="right"> 26 </TD> <TD> glycerol.no.tx </TD> <TD align="right"> 4.9 </TD> <TD align="right"> 0.8 </TD> <TD align="right"> 13.1 </TD> <TD align="right"> 4.2 </TD> <TD align="right"> 0.10735 </TD> <TD align="right"> 0.25599 </TD> </TR>
  <TR> <TD align="right"> 31 </TD> <TD> weight </TD> <TD align="right"> 89.4 </TD> <TD align="right"> 6.7 </TD> <TD align="right"> 103.9 </TD> <TD align="right"> 9.3 </TD> <TD align="right"> 0.21028 </TD> <TD align="right"> 0.43588 </TD> </TR>
  <TR> <TD align="right"> 16 </TD> <TD> Glu.Cer.C16 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 0.21091 </TD> <TD align="right"> 0.43588 </TD> </TR>
  <TR> <TD align="right"> 15 </TD> <TD> Creatinine </TD> <TD align="right"> 0.9 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 0.8 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 0.23710 </TD> <TD align="right"> 0.45937 </TD> </TR>
  <TR> <TD align="right"> 18 </TD> <TD> Glu.Cer.C18.1 </TD> <TD align="right"> 0.2 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.2 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.32498 </TD> <TD align="right"> 0.59260 </TD> </TR>
  <TR> <TD align="right"> 30 </TD> <TD> largest.diameter.of.tumor </TD> <TD align="right"> 2.0 </TD> <TD align="right"> 0.2 </TD> <TD align="right"> 1.7 </TD> <TD align="right"> 0.3 </TD> <TD align="right"> 0.36331 </TD> <TD align="right"> 0.62571 </TD> </TR>
  <TR> <TD align="right"> 12 </TD> <TD> Cer.C22..area. </TD> <TD align="right"> 7164.8 </TD> <TD align="right"> 1260.3 </TD> <TD align="right"> 9530.4 </TD> <TD align="right"> 3147.3 </TD> <TD align="right"> 0.43251 </TD> <TD align="right"> 0.70568 </TD> </TR>
  <TR> <TD align="right"> 10 </TD> <TD> Cer.C18.1 </TD> <TD align="right"> 0.7 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.7 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.51421 </TD> <TD align="right"> 0.79703 </TD> </TR>
  <TR> <TD align="right"> 1 </TD> <TD> abdominal.circumference </TD> <TD align="right"> 100.7 </TD> <TD align="right"> 4.6 </TD> <TD align="right"> 104.9 </TD> <TD align="right"> 6.3 </TD> <TD align="right"> 0.58776 </TD> <TD align="right"> 0.81898 </TD> </TR>
  <TR> <TD align="right"> 5 </TD> <TD> AST </TD> <TD align="right"> 23.5 </TD> <TD align="right"> 1.5 </TD> <TD align="right"> 22.1 </TD> <TD align="right"> 2.5 </TD> <TD align="right"> 0.61192 </TD> <TD align="right"> 0.81898 </TD> </TR>
  <TR> <TD align="right"> 20 </TD> <TD> glycerol.ins.ctrl </TD> <TD align="right"> 1.1 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 1.1 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 0.61304 </TD> <TD align="right"> 0.81898 </TD> </TR>
  <TR> <TD align="right"> 4 </TD> <TD> ALT </TD> <TD align="right"> 23.5 </TD> <TD align="right"> 2.0 </TD> <TD align="right"> 25.2 </TD> <TD align="right"> 2.9 </TD> <TD align="right"> 0.63405 </TD> <TD align="right"> 0.81898 </TD> </TR>
  <TR> <TD align="right"> 6 </TD> <TD> BMI </TD> <TD align="right"> 30.7 </TD> <TD align="right"> 1.8 </TD> <TD align="right"> 31.7 </TD> <TD align="right"> 2.1 </TD> <TD align="right"> 0.69818 </TD> <TD align="right"> 0.86574 </TD> </TR>
  <TR> <TD align="right"> 25 </TD> <TD> glycerol.iso.ctrl </TD> <TD align="right"> 1.5 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 1.6 </TD> <TD align="right"> 0.5 </TD> <TD align="right"> 0.78890 </TD> <TD align="right"> 0.94061 </TD> </TR>
  <TR> <TD align="right"> 9 </TD> <TD> Cer.C18 </TD> <TD align="right"> 0.4 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.4 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.83600 </TD> <TD align="right"> 0.95985 </TD> </TR>
  <TR> <TD align="right"> 14 </TD> <TD> Cer.C24.1..area. </TD> <TD align="right"> 7723.5 </TD> <TD align="right"> 2072.9 </TD> <TD align="right"> 7319.0 </TD> <TD align="right"> 2454.8 </TD> <TD align="right"> 0.90271 </TD> <TD align="right"> 0.98238 </TD> </TR>
  <TR> <TD align="right"> 17 </TD> <TD> Glu.Cer.C18 </TD> <TD align="right"> 0.4 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.4 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.91900 </TD> <TD align="right"> 0.98238 </TD> </TR>
  <TR> <TD align="right"> 11 </TD> <TD> Cer.C20 </TD> <TD align="right"> 0.6 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 0.6 </TD> <TD align="right"> 0.0 </TD> <TD align="right"> 1.00000 </TD> <TD align="right"> 1.00000 </TD> </TR>
  <TR> <TD align="right"> 22 </TD> <TD> glycerol.ins.iso.iso </TD> <TD align="right"> 0.9 </TD> <TD align="right"> 0.1 </TD> <TD align="right"> 1.5 </TD> <TD align="right"> 0.6 </TD> <TD align="right"> 1.00000 </TD> <TD align="right"> 1.00000 </TD> </TR>
   </TABLE>


Graphs
------

## Barplots

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots1.png) 

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots2.png) ![plot of chunk barplots](figure/barplots3.png) 

```
## pdf 
##   2
```

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots4.png) 

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots5.png) 

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots6.png) 

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots7.png) 

```
## pdf 
##   2
```

![plot of chunk barplots](figure/barplots8.png) 


Correlation with BMI
-----------------------




The BMI significantly correlated with the natural logarithm of the BMI (p=0.0215, r=0.5372, R2=0.2886)To correct for the BMI effect on the HOMA-IR score, I generated a linear model comparing the HOMA score to the BMI and the diagnosis.  We tested for an interaction between HOMA-IR and BMI in this model, and did not observe any evidence of an interaction (p=0.6167).

<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Mar  2 08:48:10 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> Estimate </TH> <TH> Std. Error </TH> <TH> t value </TH> <TH> Pr(&gt |t|) </TH>  </TR>
  <TR> <TD align="right"> (Intercept) </TD> <TD align="right"> -1.2268 </TD> <TD align="right"> 0.6719 </TD> <TD align="right"> -1.83 </TD> <TD align="right"> 0.0879 </TD> </TR>
  <TR> <TD align="right"> BMI </TD> <TD align="right"> 0.0602 </TD> <TD align="right"> 0.0210 </TD> <TD align="right"> 2.86 </TD> <TD align="right"> 0.0118 </TD> </TR>
  <TR> <TD align="right"> diagnosisAcromegaly </TD> <TD align="right"> 0.9085 </TD> <TD align="right"> 0.2529 </TD> <TD align="right"> 3.59 </TD> <TD align="right"> 0.0027 </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Mar  2 08:48:10 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> 2.5 % </TH> <TH> 97.5 % </TH>  </TR>
  <TR> <TD align="right"> (Intercept) </TD> <TD align="right"> 0.07 </TD> <TD align="right"> 1.23 </TD> </TR>
  <TR> <TD align="right"> BMI </TD> <TD align="right"> 1.02 </TD> <TD align="right"> 1.11 </TD> </TR>
  <TR> <TD align="right"> diagnosisAcromegaly </TD> <TD align="right"> 1.45 </TD> <TD align="right"> 4.25 </TD> </TR>
   </TABLE>


The results of this linear model are a significant main effect of both BMI (p=0.0118) and the diagnosis (p=0.0027) with a r-squared value of 0.5667.  This corresponds to an effect size of 2.4807.

### Model Plot


```r
pdf("../figures/BMI-HOMA Correlation.pdf")
with(acromegaly.data, plot(BMI, log(HOMA.IR), pch = 19, las = 1, col = diagnosis, 
    ylab = "Log HOMA-IR Score", xlab = "BMI (mg/kg2)"))
legend("topleft", levels(acromegaly.data$diagnosis)[1:2], pch = 19, bty = "n", 
    col = palette()[1:2], lty = 1)
with(acromegaly.data[acromegaly.data$diagnosis == "Control" & acromegaly.data$id != 
    "29", ], abline(lm(log(HOMA.IR) ~ BMI), col = palette()[1]))
with(acromegaly.data[acromegaly.data$diagnosis == "Acromegaly" & acromegaly.data$id != 
    "29", ], abline(lm(log(HOMA.IR) ~ BMI), col = palette()[2]))
dev.off()
```

```
## pdf 
##   2
```

### Model Diagnostics
![plot of chunk model-diagnostic-plots](figure/model-diagnostic-plots.png) 


Separation out of Outlier Data
--------------------------------

One subject was identified as an outlier based on the heatmap.  This was sample 12100, subject #29.





```
## pdf 
##   2
```

```
## pdf 
##   2
```

```
## pdf 
##   2
```

```
## Error: cannot mix zero-length and non-zero-length coordinates
```

```
## Error: non-conformable arrays
```

```
## pdf 
##   2
```

```
## Error: cannot mix zero-length and non-zero-length coordinates
```

```
## Error: non-conformable arrays
```

```
## pdf 
##   2
```

```
## pdf 
##   2
```


References
-----------

- John Fox, Sanford Weisberg,   (2011) An {R} Companion to Applied Regression.  <a href="http://socserv.socsci.mcmaster.ca/jfox/Books/Companion">http://socserv.socsci.mcmaster.ca/jfox/Books/Companion</a>


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
## [1] xtable_1.7-1        car_2.0-19          knitcitations_0.5-0
## [4] bibtex_0.3-6        plyr_1.8            reshape2_1.2.2     
## [7] knitr_1.5          
## 
## loaded via a namespace (and not attached):
##  [1] digest_0.6.4   evaluate_0.5.1 formatR_0.10   httr_0.2      
##  [5] MASS_7.3-29    nnet_7.3-7     RCurl_1.95-4.1 stringr_0.6.2 
##  [9] tools_3.0.2    XML_3.95-0.2
```

