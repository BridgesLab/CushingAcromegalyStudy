GOSeq of DESeq Data for Acromegaly and Cushing's Patients
=============================================================

This script was most recently run on Sun Nov 17 16:49:18 2013.  This script searches KEGG and GO for enriched categories and pathways.





To analyse these, we used the goseq package (<a href="">Young et al. 2010</a>), using the wallenius approximation to determine
significantly enriched GO (<a href="http://dx.doi.org/10.1038/75556">Botstein et al. 2000</a>) or KEGG (<a href="http://dx.doi.org/10.1093/nar/gkr988">Kanehisa et al. 2011</a>) terms.  

This analysis uses the GO database updated with the datestamp 20130907 downloaded from ftp://ftp.geneontology.org/pub/go/godatabase/archive/latest-lite/.  The KEGG database was downloaded from ftp://ftp.genome.jp/pub/kegg/genomes with a datestamp of 2011-Mar15.

This analysis included the 16 significant cushing transcripts (17 genes) and the 103 significant acromegaly transcripts (104 genes).  We did not separate upregulated genes from downregulated genes in this analysis.

![plot of chunk goseq-analysis](figure/goseq-analysis1.png) ![plot of chunk goseq-analysis](figure/goseq-analysis2.png) 


Significantly different terms and pathways
----------------------------------------------

### Cushing Significant Processes

For cushing, we found 0 significantly different GO terms for molecular function, 0 significantly different GO terms for biological processes and 0 significantly different KEGG pathways.

### Acromegaly Significant Processes

For acromegaly, we found 1 significantly different GO terms for molecular function, 85 significantly different GO terms for biological processes and 2 significantly different KEGG pathways.

<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Nov 17 16:51:22 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Biological Processes Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 3841 </TD> <TD> GO:0006694 </TD> <TD align="right"> 6 </TD> <TD align="right"> 136 </TD> <TD align="right"> 0.00754 </TD> <TD> steroid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 4136 </TD> <TD> GO:0006796 </TD> <TD align="right"> 22 </TD> <TD align="right"> 2411 </TD> <TD align="right"> 0.00754 </TD> <TD> phosphate-containing compound metabolic process </TD> </TR>
  <TR> <TD align="right"> 4638 </TD> <TD> GO:0007166 </TD> <TD align="right"> 22 </TD> <TD align="right"> 2414 </TD> <TD align="right"> 0.00754 </TD> <TD> cell surface receptor signaling pathway </TD> </TR>
  <TR> <TD align="right"> 6301 </TD> <TD> GO:0009967 </TD> <TD align="right"> 13 </TD> <TD align="right"> 853 </TD> <TD align="right"> 0.00754 </TD> <TD> positive regulation of signal transduction </TD> </TR>
  <TR> <TD align="right"> 6574 </TD> <TD> GO:0010646 </TD> <TD align="right"> 21 </TD> <TD align="right"> 2156 </TD> <TD align="right"> 0.00754 </TD> <TD> regulation of cell communication </TD> </TR>
  <TR> <TD align="right"> 6575 </TD> <TD> GO:0010647 </TD> <TD align="right"> 13 </TD> <TD align="right"> 898 </TD> <TD align="right"> 0.00754 </TD> <TD> positive regulation of cell communication </TD> </TR>
  <TR> <TD align="right"> 8844 </TD> <TD> GO:0023051 </TD> <TD align="right"> 21 </TD> <TD align="right"> 2152 </TD> <TD align="right"> 0.00754 </TD> <TD> regulation of signaling </TD> </TR>
  <TR> <TD align="right"> 8851 </TD> <TD> GO:0023056 </TD> <TD align="right"> 13 </TD> <TD align="right"> 895 </TD> <TD align="right"> 0.00754 </TD> <TD> positive regulation of signaling </TD> </TR>
  <TR> <TD align="right"> 11671 </TD> <TD> GO:0032879 </TD> <TD align="right"> 18 </TD> <TD align="right"> 1439 </TD> <TD align="right"> 0.00754 </TD> <TD> regulation of localization </TD> </TR>
  <TR> <TD align="right"> 20375 </TD> <TD> GO:0050673 </TD> <TD align="right"> 8 </TD> <TD align="right"> 249 </TD> <TD align="right"> 0.00754 </TD> <TD> epithelial cell proliferation </TD> </TR>
  <TR> <TD align="right"> 4135 </TD> <TD> GO:0006793 </TD> <TD align="right"> 22 </TD> <TD align="right"> 2457 </TD> <TD align="right"> 0.00789 </TD> <TD> phosphorus metabolic process </TD> </TR>
  <TR> <TD align="right"> 9148 </TD> <TD> GO:0030334 </TD> <TD align="right"> 9 </TD> <TD align="right"> 406 </TD> <TD align="right"> 0.00789 </TD> <TD> regulation of cell migration </TD> </TR>
  <TR> <TD align="right"> 10229 </TD> <TD> GO:0031649 </TD> <TD align="right"> 3 </TD> <TD align="right"> 13 </TD> <TD align="right"> 0.00789 </TD> <TD> heat generation </TD> </TR>
  <TR> <TD align="right"> 17853 </TD> <TD> GO:0045834 </TD> <TD align="right"> 5 </TD> <TD align="right"> 97 </TD> <TD align="right"> 0.01064 </TD> <TD> positive regulation of lipid metabolic process </TD> </TR>
  <TR> <TD align="right"> 30471 </TD> <TD> GO:2000145 </TD> <TD align="right"> 9 </TD> <TD align="right"> 429 </TD> <TD align="right"> 0.01064 </TD> <TD> regulation of cell motility </TD> </TR>
  <TR> <TD align="right"> 3356 </TD> <TD> GO:0006468 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1126 </TD> <TD align="right"> 0.01322 </TD> <TD> protein phosphorylation </TD> </TR>
  <TR> <TD align="right"> 18202 </TD> <TD> GO:0045940 </TD> <TD align="right"> 3 </TD> <TD align="right"> 19 </TD> <TD align="right"> 0.01322 </TD> <TD> positive regulation of steroid metabolic process </TD> </TR>
  <TR> <TD align="right"> 31536 </TD> <TD> GO:2001237 </TD> <TD align="right"> 4 </TD> <TD align="right"> 50 </TD> <TD align="right"> 0.01322 </TD> <TD> negative regulation of extrinsic apoptotic signaling pathway </TD> </TR>
  <TR> <TD align="right"> 13886 </TD> <TD> GO:0040012 </TD> <TD align="right"> 9 </TD> <TD align="right"> 463 </TD> <TD align="right"> 0.01446 </TD> <TD> regulation of locomotion </TD> </TR>
  <TR> <TD align="right"> 24973 </TD> <TD> GO:0070887 </TD> <TD align="right"> 18 </TD> <TD align="right"> 1892 </TD> <TD align="right"> 0.01446 </TD> <TD> cellular response to chemical stimulus </TD> </TR>
  <TR> <TD align="right"> 486 </TD> <TD> GO:0001503 </TD> <TD align="right"> 7 </TD> <TD align="right"> 281 </TD> <TD align="right"> 0.01965 </TD> <TD> ossification </TD> </TR>
  <TR> <TD align="right"> 19962 </TD> <TD> GO:0048584 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1247 </TD> <TD align="right"> 0.01965 </TD> <TD> positive regulation of response to stimulus </TD> </TR>
  <TR> <TD align="right"> 15914 </TD> <TD> GO:0043567 </TD> <TD align="right"> 3 </TD> <TD align="right"> 22 </TD> <TD align="right"> 0.01971 </TD> <TD> regulation of insulin-like growth factor receptor signaling pathway </TD> </TR>
  <TR> <TD align="right"> 20039 </TD> <TD> GO:0048660 </TD> <TD align="right"> 4 </TD> <TD align="right"> 66 </TD> <TD align="right"> 0.01971 </TD> <TD> regulation of smooth muscle cell proliferation </TD> </TR>
  <TR> <TD align="right"> 21645 </TD> <TD> GO:0051270 </TD> <TD align="right"> 9 </TD> <TD align="right"> 490 </TD> <TD align="right"> 0.01971 </TD> <TD> regulation of cellular component movement </TD> </TR>
  <TR> <TD align="right"> 6298 </TD> <TD> GO:0009966 </TD> <TD align="right"> 18 </TD> <TD align="right"> 1916 </TD> <TD align="right"> 0.01990 </TD> <TD> regulation of signal transduction </TD> </TR>
  <TR> <TD align="right"> 7932 </TD> <TD> GO:0019218 </TD> <TD align="right"> 4 </TD> <TD align="right"> 65 </TD> <TD align="right"> 0.01990 </TD> <TD> regulation of steroid metabolic process </TD> </TR>
  <TR> <TD align="right"> 20038 </TD> <TD> GO:0048659 </TD> <TD align="right"> 4 </TD> <TD align="right"> 69 </TD> <TD align="right"> 0.02110 </TD> <TD> smooth muscle cell proliferation </TD> </TR>
  <TR> <TD align="right"> 5330 </TD> <TD> GO:0008610 </TD> <TD align="right"> 9 </TD> <TD align="right"> 557 </TD> <TD align="right"> 0.02149 </TD> <TD> lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 7507 </TD> <TD> GO:0016310 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1269 </TD> <TD align="right"> 0.02149 </TD> <TD> phosphorylation </TD> </TR>
  <TR> <TD align="right"> 7935 </TD> <TD> GO:0019220 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1261 </TD> <TD align="right"> 0.02149 </TD> <TD> regulation of phosphate metabolic process </TD> </TR>
  <TR> <TD align="right"> 18589 </TD> <TD> GO:0046165 </TD> <TD align="right"> 5 </TD> <TD align="right"> 134 </TD> <TD align="right"> 0.02149 </TD> <TD> alcohol biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 21455 </TD> <TD> GO:0051174 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1274 </TD> <TD align="right"> 0.02149 </TD> <TD> regulation of phosphorus metabolic process </TD> </TR>
  <TR> <TD align="right"> 22779 </TD> <TD> GO:0051897 </TD> <TD align="right"> 4 </TD> <TD align="right"> 66 </TD> <TD align="right"> 0.02149 </TD> <TD> positive regulation of protein kinase B signaling cascade </TD> </TR>
  <TR> <TD align="right"> 7929 </TD> <TD> GO:0019216 </TD> <TD align="right"> 6 </TD> <TD align="right"> 214 </TD> <TD align="right"> 0.02246 </TD> <TD> regulation of lipid metabolic process </TD> </TR>
  <TR> <TD align="right"> 928 </TD> <TD> GO:0001932 </TD> <TD align="right"> 11 </TD> <TD align="right"> 826 </TD> <TD align="right"> 0.02325 </TD> <TD> regulation of protein phosphorylation </TD> </TR>
  <TR> <TD align="right"> 9154 </TD> <TD> GO:0030336 </TD> <TD align="right"> 5 </TD> <TD align="right"> 129 </TD> <TD align="right"> 0.02543 </TD> <TD> negative regulation of cell migration </TD> </TR>
  <TR> <TD align="right"> 15932 </TD> <TD> GO:0043570 </TD> <TD align="right"> 2 </TD> <TD align="right"> 4 </TD> <TD align="right"> 0.02569 </TD> <TD> maintenance of DNA repeat elements </TD> </TR>
  <TR> <TD align="right"> 573 </TD> <TD> GO:0001659 </TD> <TD align="right"> 3 </TD> <TD align="right"> 28 </TD> <TD align="right"> 0.02640 </TD> <TD> temperature homeostasis </TD> </TR>
  <TR> <TD align="right"> 25315 </TD> <TD> GO:0071462 </TD> <TD align="right"> 2 </TD> <TD align="right"> 4 </TD> <TD align="right"> 0.02640 </TD> <TD> cellular response to water stimulus </TD> </TR>
  <TR> <TD align="right"> 30311 </TD> <TD> GO:2000026 </TD> <TD align="right"> 13 </TD> <TD align="right"> 1152 </TD> <TD align="right"> 0.02640 </TD> <TD> regulation of multicellular organismal development </TD> </TR>
  <TR> <TD align="right"> 30474 </TD> <TD> GO:2000146 </TD> <TD align="right"> 5 </TD> <TD align="right"> 132 </TD> <TD align="right"> 0.02640 </TD> <TD> negative regulation of cell motility </TD> </TR>
  <TR> <TD align="right"> 21647 </TD> <TD> GO:0051271 </TD> <TD align="right"> 5 </TD> <TD align="right"> 137 </TD> <TD align="right"> 0.02904 </TD> <TD> negative regulation of cellular component movement </TD> </TR>
  <TR> <TD align="right"> 2731 </TD> <TD> GO:0006066 </TD> <TD align="right"> 7 </TD> <TD align="right"> 349 </TD> <TD align="right"> 0.03104 </TD> <TD> alcohol metabolic process </TD> </TR>
  <TR> <TD align="right"> 21565 </TD> <TD> GO:0051239 </TD> <TD align="right"> 17 </TD> <TD align="right"> 1915 </TD> <TD align="right"> 0.03209 </TD> <TD> regulation of multicellular organismal process </TD> </TR>
  <TR> <TD align="right"> 5168 </TD> <TD> GO:0008202 </TD> <TD align="right"> 6 </TD> <TD align="right"> 262 </TD> <TD align="right"> 0.03249 </TD> <TD> steroid metabolic process </TD> </TR>
  <TR> <TD align="right"> 7533 </TD> <TD> GO:0016477 </TD> <TD align="right"> 11 </TD> <TD align="right"> 858 </TD> <TD align="right"> 0.03249 </TD> <TD> cell migration </TD> </TR>
  <TR> <TD align="right"> 14315 </TD> <TD> GO:0042325 </TD> <TD align="right"> 11 </TD> <TD align="right"> 882 </TD> <TD align="right"> 0.03249 </TD> <TD> regulation of phosphorylation </TD> </TR>
  <TR> <TD align="right"> 31532 </TD> <TD> GO:2001234 </TD> <TD align="right"> 4 </TD> <TD align="right"> 86 </TD> <TD align="right"> 0.03249 </TD> <TD> negative regulation of apoptotic signaling pathway </TD> </TR>
  <TR> <TD align="right"> 19961 </TD> <TD> GO:0048583 </TD> <TD align="right"> 20 </TD> <TD align="right"> 2536 </TD> <TD align="right"> 0.03339 </TD> <TD> regulation of response to stimulus </TD> </TR>
  <TR> <TD align="right"> 574 </TD> <TD> GO:0001660 </TD> <TD align="right"> 2 </TD> <TD align="right"> 7 </TD> <TD align="right"> 0.03436 </TD> <TD> fever generation </TD> </TR>
  <TR> <TD align="right"> 6576 </TD> <TD> GO:0010648 </TD> <TD align="right"> 10 </TD> <TD align="right"> 749 </TD> <TD align="right"> 0.03436 </TD> <TD> negative regulation of cell communication </TD> </TR>
  <TR> <TD align="right"> 8853 </TD> <TD> GO:0023057 </TD> <TD align="right"> 10 </TD> <TD align="right"> 747 </TD> <TD align="right"> 0.03436 </TD> <TD> negative regulation of signaling </TD> </TR>
  <TR> <TD align="right"> 10183 </TD> <TD> GO:0031620 </TD> <TD align="right"> 2 </TD> <TD align="right"> 7 </TD> <TD align="right"> 0.03436 </TD> <TD> regulation of fever generation </TD> </TR>
  <TR> <TD align="right"> 10184 </TD> <TD> GO:0031622 </TD> <TD align="right"> 2 </TD> <TD align="right"> 7 </TD> <TD align="right"> 0.03436 </TD> <TD> positive regulation of fever generation </TD> </TR>
  <TR> <TD align="right"> 13887 </TD> <TD> GO:0040013 </TD> <TD align="right"> 5 </TD> <TD align="right"> 151 </TD> <TD align="right"> 0.03436 </TD> <TD> negative regulation of locomotion </TD> </TR>
  <TR> <TD align="right"> 21847 </TD> <TD> GO:0051345 </TD> <TD align="right"> 8 </TD> <TD align="right"> 476 </TD> <TD align="right"> 0.03436 </TD> <TD> positive regulation of hydrolase activity </TD> </TR>
  <TR> <TD align="right"> 31534 </TD> <TD> GO:2001236 </TD> <TD align="right"> 4 </TD> <TD align="right"> 88 </TD> <TD align="right"> 0.03436 </TD> <TD> regulation of extrinsic apoptotic signaling pathway </TD> </TR>
  <TR> <TD align="right"> 9106 </TD> <TD> GO:0030282 </TD> <TD align="right"> 4 </TD> <TD align="right"> 87 </TD> <TD align="right"> 0.03620 </TD> <TD> bone mineralization </TD> </TR>
  <TR> <TD align="right"> 21806 </TD> <TD> GO:0051336 </TD> <TD align="right"> 10 </TD> <TD align="right"> 777 </TD> <TD align="right"> 0.03620 </TD> <TD> regulation of hydrolase activity </TD> </TR>
  <TR> <TD align="right"> 22524 </TD> <TD> GO:0051716 </TD> <TD align="right"> 31 </TD> <TD align="right"> 5138 </TD> <TD align="right"> 0.03620 </TD> <TD> cellular response to stimulus </TD> </TR>
  <TR> <TD align="right"> 28942 </TD> <TD> GO:1901617 </TD> <TD align="right"> 5 </TD> <TD align="right"> 172 </TD> <TD align="right"> 0.03620 </TD> <TD> organic hydroxy compound biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 6662 </TD> <TD> GO:0010740 </TD> <TD align="right"> 8 </TD> <TD align="right"> 500 </TD> <TD align="right"> 0.03646 </TD> <TD> positive regulation of intracellular protein kinase cascade </TD> </TR>
  <TR> <TD align="right"> 14176 </TD> <TD> GO:0042221 </TD> <TD align="right"> 21 </TD> <TD align="right"> 2889 </TD> <TD align="right"> 0.03842 </TD> <TD> response to chemical stimulus </TD> </TR>
  <TR> <TD align="right"> 16216 </TD> <TD> GO:0044281 </TD> <TD align="right"> 19 </TD> <TD align="right"> 2566 </TD> <TD align="right"> 0.03947 </TD> <TD> small molecule metabolic process </TD> </TR>
  <TR> <TD align="right"> 1201 </TD> <TD> GO:0002118 </TD> <TD align="right"> 2 </TD> <TD align="right"> 8 </TD> <TD align="right"> 0.04032 </TD> <TD> aggressive behavior </TD> </TR>
  <TR> <TD align="right"> 6005 </TD> <TD> GO:0009415 </TD> <TD align="right"> 2 </TD> <TD align="right"> 7 </TD> <TD align="right"> 0.04032 </TD> <TD> response to water stimulus </TD> </TR>
  <TR> <TD align="right"> 6255 </TD> <TD> GO:0009893 </TD> <TD align="right"> 17 </TD> <TD align="right"> 2044 </TD> <TD align="right"> 0.04032 </TD> <TD> positive regulation of metabolic process </TD> </TR>
  <TR> <TD align="right"> 19480 </TD> <TD> GO:0048009 </TD> <TD align="right"> 3 </TD> <TD align="right"> 35 </TD> <TD align="right"> 0.04032 </TD> <TD> insulin-like growth factor receptor signaling pathway </TD> </TR>
  <TR> <TD align="right"> 19853 </TD> <TD> GO:0048518 </TD> <TD align="right"> 24 </TD> <TD align="right"> 3547 </TD> <TD align="right"> 0.04032 </TD> <TD> positive regulation of biological process </TD> </TR>
  <TR> <TD align="right"> 22774 </TD> <TD> GO:0051896 </TD> <TD align="right"> 4 </TD> <TD align="right"> 93 </TD> <TD align="right"> 0.04032 </TD> <TD> regulation of protein kinase B signaling cascade </TD> </TR>
  <TR> <TD align="right"> 20247 </TD> <TD> GO:0048870 </TD> <TD align="right"> 11 </TD> <TD align="right"> 928 </TD> <TD align="right"> 0.04156 </TD> <TD> cell motility </TD> </TR>
  <TR> <TD align="right"> 22482 </TD> <TD> GO:0051674 </TD> <TD align="right"> 11 </TD> <TD align="right"> 928 </TD> <TD align="right"> 0.04156 </TD> <TD> localization of cell </TD> </TR>
  <TR> <TD align="right"> 4673 </TD> <TD> GO:0007178 </TD> <TD align="right"> 6 </TD> <TD align="right"> 272 </TD> <TD align="right"> 0.04287 </TD> <TD> transmembrane receptor protein serine/threonine kinase signaling pathway </TD> </TR>
  <TR> <TD align="right"> 19388 </TD> <TD> GO:0046890 </TD> <TD align="right"> 4 </TD> <TD align="right"> 98 </TD> <TD align="right"> 0.04287 </TD> <TD> regulation of lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 21575 </TD> <TD> GO:0051246 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1523 </TD> <TD align="right"> 0.04325 </TD> <TD> regulation of protein metabolic process </TD> </TR>
  <TR> <TD align="right"> 29099 </TD> <TD> GO:1901701 </TD> <TD align="right"> 9 </TD> <TD align="right"> 658 </TD> <TD align="right"> 0.04373 </TD> <TD> cellular response to oxygen-containing compound </TD> </TR>
  <TR> <TD align="right"> 19875 </TD> <TD> GO:0048522 </TD> <TD align="right"> 22 </TD> <TD align="right"> 3149 </TD> <TD align="right"> 0.04472 </TD> <TD> positive regulation of cellular process </TD> </TR>
  <TR> <TD align="right"> 5200 </TD> <TD> GO:0008283 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1546 </TD> <TD align="right"> 0.04474 </TD> <TD> cell proliferation </TD> </TR>
  <TR> <TD align="right"> 10235 </TD> <TD> GO:0031652 </TD> <TD align="right"> 2 </TD> <TD align="right"> 9 </TD> <TD align="right"> 0.04539 </TD> <TD> positive regulation of heat generation </TD> </TR>
  <TR> <TD align="right"> 25156 </TD> <TD> GO:0071230 </TD> <TD align="right"> 3 </TD> <TD align="right"> 37 </TD> <TD align="right"> 0.04539 </TD> <TD> cellular response to amino acid stimulus </TD> </TR>
  <TR> <TD align="right"> 19378 </TD> <TD> GO:0046889 </TD> <TD align="right"> 3 </TD> <TD align="right"> 44 </TD> <TD align="right"> 0.04658 </TD> <TD> positive regulation of lipid biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 11899 </TD> <TD> GO:0033002 </TD> <TD align="right"> 4 </TD> <TD align="right"> 105 </TD> <TD align="right"> 0.04720 </TD> <TD> muscle cell proliferation </TD> </TR>
  <TR> <TD align="right"> 16218 </TD> <TD> GO:0044283 </TD> <TD align="right"> 7 </TD> <TD align="right"> 439 </TD> <TD align="right"> 0.04773 </TD> <TD> small molecule biosynthetic process </TD> </TR>
  <TR> <TD align="right"> 16301 </TD> <TD> GO:0044710 </TD> <TD align="right"> 21 </TD> <TD align="right"> 3095 </TD> <TD align="right"> 0.04865 </TD> <TD> single-organism metabolic process </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Nov 17 16:51:22 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> Molecular Functions Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> Term </TH>  </TR>
  <TR> <TD align="right"> 6330 </TD> <TD> GO:0005102 </TD> <TD align="right"> 14 </TD> <TD align="right"> 1130 </TD> <TD align="right"> 0.02658 </TD> <TD> receptor binding </TD> </TR>
   </TABLE>
<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Sun Nov 17 16:51:22 2013 -->
<TABLE border=1>
<CAPTION ALIGN="bottom"> KEGG Pathways Enriched in Acromegaly Patients </CAPTION>
<TR> <TH>  </TH> <TH> category </TH> <TH> numDEInCat </TH> <TH> numInCat </TH> <TH> padj </TH> <TH> path_name </TH>  </TR>
  <TR> <TD align="right"> 132 </TD> <TD> 04350 </TD> <TD align="right"> 4 </TD> <TD align="right"> 84 </TD> <TD align="right"> 0.02476 </TD> <TD> TGF-beta signaling pathway </TD> </TR>
  <TR> <TD align="right"> 210 </TD> <TD> 05215 </TD> <TD align="right"> 4 </TD> <TD align="right"> 86 </TD> <TD align="right"> 0.02476 </TD> <TD> Prostate cancer </TD> </TR>
   </TABLE>


Bibiography
------------

- David Botstein, J. Michael Cherry, Michael Ashburner, Catherine A. Ball, Judith A. Blake, Heather Butler, Allan P. Davis, Kara Dolinski, Selina S. Dwight, Janan T. Eppig, Midori A. Harris, David P. Hill, Laurie Issel-Tarver, Andrew Kasarskis, Suzanna Lewis, John C. Matese, Joel E. Richardson, Martin Ringwald, Gerald M. Rubin, Gavin Sherlock,   (2000) Unknown.  <em>Nature Genetics</em>  <strong>25</strong>  25-29  <a href="http://dx.doi.org/10.1038/75556">10.1038/75556</a>
- Matthew Young, Matthew Wakefield, Gordon Smyth, Alicia Oshlack,   (2010) Gene ontology analysis for RNA-seq: accounting for selection bias.  <em>Genome Biology</em>  <strong>11</strong>  R14-NA
- M. Kanehisa, S. Goto, Y. Sato, M. Furumichi, M. Tanabe,   (2011) Kegg For Integration And Interpretation of Large-Scale Molecular Data Sets.  <em>Nucleic Acids Research</em>  <strong>40</strong>  D109-D114  <a href="http://dx.doi.org/10.1093/nar/gkr988">10.1093/nar/gkr988</a>


Session Information
-------------------

For the R session, the package versions were:

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
## [1] parallel  stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
##  [1] xtable_1.7-1            org.Hs.eg.db_2.10.1    
##  [3] KEGG.db_2.10.1          GO.db_2.10.1           
##  [5] RSQLite_0.11.4          DBI_0.2-7              
##  [7] AnnotationDbi_1.24.0    Biobase_2.22.0         
##  [9] BiocGenerics_0.8.0      goseq_1.14.0           
## [11] geneLenDataBase_0.99.12 BiasedUrn_1.06         
## [13] knitcitations_0.5-0     bibtex_0.3-6           
## [15] knitr_1.5              
## 
## loaded via a namespace (and not attached):
##  [1] biomaRt_2.18.0         Biostrings_2.30.1      bitops_1.0-6          
##  [4] BSgenome_1.30.0        digest_0.6.3           evaluate_0.5.1        
##  [7] formatR_0.10           GenomicFeatures_1.14.0 GenomicRanges_1.14.3  
## [10] grid_3.0.2             httr_0.2               IRanges_1.20.5        
## [13] lattice_0.20-24        Matrix_1.1-0           mgcv_1.7-27           
## [16] nlme_3.1-111           RCurl_1.95-4.1         Rsamtools_1.14.1      
## [19] rtracklayer_1.22.0     stats4_3.0.2           stringr_0.6.2         
## [22] tools_3.0.2            XML_3.95-0.2           XVector_0.2.0         
## [25] zlibbioc_1.8.0
```

