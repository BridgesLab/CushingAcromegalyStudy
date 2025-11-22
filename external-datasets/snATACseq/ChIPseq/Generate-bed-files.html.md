---
title: "Generation of UCSC formatted BigBed files"
author: "Dave Bridges"
date: "2025-11-22"
editor: source
format: 
  html:
    toc: true
    toc-location: right
    keep-md: true
    code-fold: true
    code-summary: "Show the code"
    fig-path: "figures/"
theme: journal
execute:
  echo: true
  warning: false
---


::: {.cell}

```{.r .cell-code}
# hide this code chunk
#| echo: false
#| message: false

# defines the se function
se <- function(x) {
  sd(x, na.rm = TRUE) / sqrt(length(x))
}

#load these packages, nearly always needed
library(tidyverse)

# sets maize and blue color scheme
color_scheme <- c("#00274c", "#ffcb05")
```
:::


## Purpose

Convert into excel files into BED files

## Experimental Details


## Raw Data

Data from Ying *et al.,* 2010 at http://dx.doi.org/10.1371/journal.pone.0015188


::: {.cell}

```{.r .cell-code}
library(readxl) #loads the readr package
filename <- "pone.0015188.s001.xls" #input file(s)

exp.data <- read_excel(filename, skip=1)
#BiocManager::install("rtracklayer")
library(rtracklayer)
bed <- exp.data |>
  mutate(chrom= `chromosome number`,
         chromsStart = startpeak - 1,  # convert to 0-based
         chromEnd   = endpeak,
         name = `user defined string`,
         score = 0,
         strand = '.') |>
  select(chrom, chromsStart, chromEnd, name, score, strand) |>
  na.omit()

bed.filename <- "pone.0015188.s001.bed"
write_tsv(bed, bed.filename, col_names = FALSE)
```
:::


Had to convert this from mm9 to mm10 by liftover at https://genome.ucsc.edu/cgi-bin/hgLiftOver.  

Then converted to bigbed with this command


::: {.cell}

```{.r .cell-code}
read_tsv('../GSE236575/results/motif_analysis/bed_files/HFD_specific_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('HFD_specific_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_HFD_specific.bed', col_names = FALSE)

read_tsv('../GSE236575/results/motif_analysis/bed_files/CHD_specific_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('NCD_specific_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_CHD_specific.bed', col_names = FALSE)

read_tsv('../GSE236575/results/motif_analysis/bed_files/shared_chr.bed', 
         col_names = c('chrom','chromStart','chromEnd')) |>
  mutate(name = paste0('shared_', row_number()),
         score = 0,
         strand = '.') |>
  write_tsv('GSE236575_shared.bed', col_names = FALSE)
```
:::


## Create BigBed files

` bedToBigBed -type=bed6 -sort pone.0015188.s001_mm10.bed mm10.chrom.sizes pone.0015188.s001.bb`
`bedToBigBed -type=bed6 -sort GSE236575_shared.bed mm10.chrom.sizes GSE236575_shared.bb`
`bedToBigBed -type=bed6 -sort GSE236575_CHD_specific.bed mm10.chrom.sizes GSE236575_CHD_specific.bb`
`bedToBigBed -type=bed6 -sort GSE236575_HFD_specific.bed mm10.chrom.sizes GSE236575_HFD_specific.bb`

## Peak Overlap


::: {.cell}

```{.r .cell-code}
library(rtracklayer)
library(GenomicRanges)
library(dplyr)

# 1. Read your two BED files (automatically handles .bed, .bed.gz, etc.)
hfd.atac_peaks  <- import("GSE236575_HFD_specific.bed")   # your ATAC peaks
ncd.atac_peaks  <- import("GSE236575_CHD_specific.bed")   # your ATAC peaks
chip_peaks  <- import("pone.0015188.s001_mm10.bed")

# 2. Make sure they are proper GRanges with names (optional but very useful)
# If your BED files have a 4th column with peak IDs, they will be used as names
# Otherwise we give them unique IDs:
if (is.null(names(hfd.atac_peaks)))  names(hfd.atac_peaks) <- paste0("ATAC_", 1:length(hfd.atac_peaks))
if (is.null(names(hfd.atac_peaks)))  names(ncd.atac_peaks) <- paste0("ATAC_", 1:length(ncd.atac_peaks))
if (is.null(names(chip_peaks)))  names(chip_peaks) <- paste0("ChIP_", 1:length(chip_peaks))

# 3. Find overlaps
# hits = which ChIP-seq peaks overlap at least one ATAC-seq peak
hfd.hits <- findOverlaps(chip_peaks, hfd.atac_peaks, type = "any", select = "all")
ncd.hits <- findOverlaps(chip_peaks, ncd.atac_peaks, type = "any", select = "all")

# 4. Extract the overlapping ChIP-seq peaks
hfd.chip_peaks_that_overlap_ATAC <- chip_peaks[queryHits(hfd.hits)]
ncd.chip_peaks_that_overlap_ATAC <- chip_peaks[queryHits(ncd.hits)]

# 5. How many ChIP-seq peaks overlap ATAC?
cat(sprintf("%d out of %d ChIP-seq peaks (%.1f%%) overlap at least one ATAC-seq peak from HFD\n",
      length(unique(queryHits(hfd.hits))),
      length(chip_peaks),
      100 * length(unique(queryHits(hfd.hits))) / length(chip_peaks)))
```

::: {.cell-output .cell-output-stdout}

```
141 out of 8845 ChIP-seq peaks (1.6%) overlap at least one ATAC-seq peak from HFD
```


:::

```{.r .cell-code}
cat(sprintf("%d out of %d ChIP-seq peaks (%.1f%%) overlap at least one ATAC-seq peak from NCD\n",
      length(unique(queryHits(ncd.hits))),
      length(chip_peaks),
      100 * length(unique(queryHits(ncd.hits))) / length(chip_peaks)))
```

::: {.cell-output .cell-output-stdout}

```
257 out of 8845 ChIP-seq peaks (2.9%) overlap at least one ATAC-seq peak from NCD
```


:::
:::


## Genes that overlap

### High Fat Diet


::: {.cell}

```{.r .cell-code}
# Get mouse gene annotation (GENCODE or Ensembl – GENCODE is preferred for mm10/GRCm38)
# This pulls the latest GENCODE M25 (matches mm10 perfectly)
genes <- import("https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.annotation.gtf.gz")

# Keep only protein-coding genes + lncRNAs if you want (optional)
genes <- genes[genes$type == "gene"]
genes <- genes[genes$gene_type %in% c("protein_coding")] #not, "lincRNA", "antisense", "processed_pseudogene")]

# Extract transcription start sites (TSS)
tss <- promoters(genes, upstream = 0, downstream = 1)   # 1-bp region at TSS
names(tss) <- genes$gene_name                              # use gene symbols

# Find closest TSS for each ChIP peak
hfd.nearest_tss_idx   <- nearest(hfd.chip_peaks_that_overlap_ATAC, tss)
hfd.distance_to_tss   <- distance(hfd.chip_peaks_that_overlap_ATAC, tss[hfd.nearest_tss_idx])

# Build the final annotation table
hfd.annotation <- data.frame(
  peak_id         = names(hfd.chip_peaks_that_overlap_ATAC),
  chr             = seqnames(hfd.chip_peaks_that_overlap_ATAC),
  start           = start(hfd.chip_peaks_that_overlap_ATAC),
  end             = end(hfd.chip_peaks_that_overlap_ATAC),
  nearest_gene    = names(tss)[hfd.nearest_tss_idx],
  gene_strand     = as.character(strand(tss[hfd.nearest_tss_idx])),
  distance_to_TSS = hfd.distance_to_tss,
  gene_id         = genes$gene_id[hfd.nearest_tss_idx],
  stringsAsFactors = FALSE
) %>% arrange(hfd.distance_to_tss)

library(knitr)
kable(hfd.annotation,caption="ChIP peaks overlapping HFD-specific ATAC peaks and their nearest genes")
```

::: {.cell-output-display}


Table: ChIP peaks overlapping HFD-specific ATAC peaks and their nearest genes

|peak_id   |chr   |     start|       end|nearest_gene  |gene_strand | distance_to_TSS|gene_id               |
|:---------|:-----|---------:|---------:|:-------------|:-----------|---------------:|:---------------------|
|ChIP_2066 |chr13 |  67818689|  67818944|Zfp273        |+           |            4948|ENSMUSG00000030446.17 |
|ChIP_8560 |chr9  |  92255247|  92255507|Plscr1        |+           |            5496|ENSMUSG00000032369.13 |
|ChIP_7276 |chr7  |  24127980|  24128483|Zfp235        |+           |            5685|ENSMUSG00000047603.9  |
|ChIP_7248 |chr6  | 149303333| 149303629|Resf1         |+           |            5784|ENSMUSG00000032712.16 |
|ChIP_7275 |chr7  |  24127261|  24127418|Zfp235        |+           |            6750|ENSMUSG00000047603.9  |
|ChIP_2560 |chr15 |  27674153|  27674564|Otulinl       |-           |            7014|ENSMUSG00000056069.10 |
|ChIP_1910 |chr13 |  32957908|  32958096|Serpinb6b     |+           |            7112|ENSMUSG00000042842.11 |
|ChIP_26   |chr1  |  23931291|  23931746|Smap1         |-           |            8973|ENSMUSG00000026155.13 |
|ChIP_4143 |chr19 |  27312627|  27313284|Kcnv2         |+           |            9303|ENSMUSG00000047298.3  |
|ChIP_4697 |chr2  |  79698262|  79698457|Ppp1r1c       |+           |            9322|ENSMUSG00000034683.12 |
|ChIP_1711 |chr12 |  87031745|  87032016|Tmem63c       |+           |           10404|ENSMUSG00000034145.14 |
|ChIP_3802 |chr18 |  12295036|  12295307|Ankrd29       |-           |           10489|ENSMUSG00000057766.14 |
|ChIP_2350 |chr14 |  45000157|  45000352|Ptger2        |+           |           11961|ENSMUSG00000037759.6  |
|ChIP_2351 |chr14 |  45000357|  45000635|Ptger2        |+           |           12161|ENSMUSG00000037759.6  |
|ChIP_4096 |chr19 |  18619101|  18619307|Ostf1         |-           |           12515|ENSMUSG00000024725.13 |
|ChIP_8724 |chrX  |  53383170|  53383568|Mospd1        |-           |           12667|ENSMUSG00000023074.11 |
|ChIP_7258 |chr7  |   7196469|   7196695|Zfp772        |-           |           13302|ENSMUSG00000066838.7  |
|ChIP_296  |chr1  | 134276279| 134276457|Myog          |+           |           13531|ENSMUSG00000026459.5  |
|ChIP_3840 |chr18 |  35676272|  35676557|Spata24       |-           |           14085|ENSMUSG00000024352.12 |
|ChIP_6647 |chr6  |   6592766|   6593153|Sem1          |-           |           14102|ENSMUSG00000042541.10 |
|ChIP_5545 |chr3  | 154582068| 154582438|Cryz          |+           |           14272|ENSMUSG00000028199.18 |
|ChIP_3879 |chr18 |  52600524|  52600917|Zfp474        |+           |           14997|ENSMUSG00000046886.6  |
|ChIP_4062 |chr19 |   9119694|   9119975|Asrgl1        |-           |           15660|ENSMUSG00000024654.8  |
|ChIP_5870 |chr4  | 115534851| 115535092|Cyp4a10       |+           |           16586|ENSMUSG00000066072.13 |
|ChIP_2122 |chr13 |  98654385|  98654629|Tmem174       |-           |           16974|ENSMUSG00000046082.4  |
|ChIP_906  |chr10 | 115333557| 115333970|Rab21         |-           |           17962|ENSMUSG00000020132.10 |
|ChIP_878  |chr10 |  97587007|  97587163|Kera          |+           |           19715|ENSMUSG00000019932.8  |
|ChIP_4055 |chr19 |   8702492|   8702672|Slc3a2        |-           |           20696|ENSMUSG00000010095.13 |
|ChIP_2680 |chr15 |  58344897|  58345207|Klhl38        |-           |           20727|ENSMUSG00000022357.2  |
|ChIP_8287 |chr9  |  32657094|  32657401|Ets1          |+           |           20872|ENSMUSG00000032035.16 |
|ChIP_6523 |chr5  | 134154308| 134154676|Rcc1l         |-           |           22097|ENSMUSG00000061979.8  |
|ChIP_7474 |chr7  |  92897187|  92897457|Prcp          |+           |           22716|ENSMUSG00000061119.7  |
|ChIP_6    |chr1  |  10255474|  10255689|Arfgef1       |-           |           22803|ENSMUSG00000067851.11 |
|ChIP_8726 |chrX  |  53694032|  53694344|Rtl8b         |-           |           23623|ENSMUSG00000067924.4  |
|ChIP_34   |chr1  |  33645720|  33646029|Prim2         |-           |           23765|ENSMUSG00000026134.11 |
|ChIP_8723 |chrX  |  53213952|  53214228|Plac1         |-           |           25882|ENSMUSG00000061082.11 |
|ChIP_100  |chr1  |  53680044|  53680248|Dnah7a        |-           |           26535|ENSMUSG00000096141.2  |
|ChIP_699  |chr10 |  58418423|  58418876|Ranbp2        |+           |           28043|ENSMUSG00000003226.7  |
|ChIP_2758 |chr15 |  68287116|  68287307|Zfat          |-           |           28259|ENSMUSG00000022335.17 |
|ChIP_4076 |chr19 |  11995026|  11995212|Osbp          |+           |           29084|ENSMUSG00000024687.11 |
|ChIP_698  |chr10 |  58416774|  58416972|Ranbp2        |+           |           29947|ENSMUSG00000003226.7  |
|ChIP_8747 |chrX  |  72887902|  72888163|Cetn2         |-           |           30247|ENSMUSG00000031347.12 |
|ChIP_5621 |chr4  |  43350296|  43350515|Rusc2         |+           |           31463|ENSMUSG00000035969.15 |
|ChIP_211  |chr1  |  90876549|  90876800|Col6a3        |-           |           32577|ENSMUSG00000048126.16 |
|ChIP_7252 |chr7  |   3457315|   3457604|Cacng6        |+           |           33119|ENSMUSG00000078815.8  |
|ChIP_5752 |chr4  |  86712579|  86713007|Dennd4c       |+           |           35547|ENSMUSG00000038024.17 |
|ChIP_5563 |chr4  |   6239590|   6239847|Cyp7a1        |-           |           35785|ENSMUSG00000028240.2  |
|ChIP_3207 |chr16 |  50552573|  50552763|Ccdc54        |-           |           38390|ENSMUSG00000050685.5  |
|ChIP_7253 |chr7  |   3463304|   3463625|Tarm1         |-           |           38998|ENSMUSG00000053338.9  |
|ChIP_6777 |chr6  |  41911720|  41911985|Sval1         |+           |           39644|ENSMUSG00000029865.4  |
|ChIP_7    |chr1  |  11033656|  11033905|Prex2         |+           |           40190|ENSMUSG00000048960.13 |
|ChIP_4911 |chr2  | 140107687| 140108024|Tasp1         |-           |           40881|ENSMUSG00000039033.11 |
|ChIP_4912 |chr2  | 140108119| 140108318|Tasp1         |-           |           41313|ENSMUSG00000039033.11 |
|ChIP_5425 |chr3  | 115845784| 115846085|Dph5          |+           |           41751|ENSMUSG00000033554.17 |
|ChIP_7452 |chr7  |  83541547|  83541839|Tmc3          |+           |           43087|ENSMUSG00000038540.14 |
|ChIP_4141 |chr19 |  27260184|  27260625|Vldlr         |+           |           43699|ENSMUSG00000024924.14 |
|ChIP_4142 |chr19 |  27260666|  27261066|Vldlr         |+           |           44181|ENSMUSG00000024924.14 |
|ChIP_325  |chr1  | 143823851| 143824141|Uchl5         |+           |           46578|ENSMUSG00000018189.12 |
|ChIP_3640 |chr17 |  71134677|  71134895|Lpin2         |+           |           47664|ENSMUSG00000024052.17 |
|ChIP_7247 |chr6  | 149260928| 149261261|Resf1         |+           |           48152|ENSMUSG00000032712.16 |
|ChIP_8416 |chr9  |  57391250|  57391439|Ppcdc         |-           |           48684|ENSMUSG00000063849.6  |
|ChIP_8415 |chr9  |  57390905|  57391141|Ppcdc         |-           |           48982|ENSMUSG00000063849.6  |
|ChIP_3092 |chr16 |  26630724|  26631013|Il1rap        |+           |           49019|ENSMUSG00000022514.14 |
|ChIP_7552 |chr7  | 111730369| 111730674|Galnt18       |-           |           49302|ENSMUSG00000038296.14 |
|ChIP_396  |chr1  | 160100940| 160101381|Tnn           |-           |           52198|ENSMUSG00000026725.17 |
|ChIP_4373 |chr2  |   3166899|   3167178|Fam171a1      |+           |           52674|ENSMUSG00000050530.14 |
|ChIP_7551 |chr7  | 111726880| 111727117|Galnt18       |-           |           52859|ENSMUSG00000038296.14 |
|ChIP_4710 |chr2  |  90521869|  90522195|Ptprj         |-           |           58451|ENSMUSG00000025314.16 |
|ChIP_6379 |chr5  | 104567282| 104567491|Thoc2l        |+           |           58931|ENSMUSG00000097392.4  |
|ChIP_7550 |chr7  | 111719992| 111720249|Galnt18       |-           |           59727|ENSMUSG00000038296.14 |
|ChIP_2246 |chr14 |  19887597|  19887901|Rtraf         |-           |           63772|ENSMUSG00000021807.6  |
|ChIP_4220 |chr19 |  38753962|  38754335|Noc3l         |-           |           64901|ENSMUSG00000024999.7  |
|ChIP_13   |chr1  |  14244823|  14245100|Eya1          |-           |           65134|ENSMUSG00000025932.14 |
|ChIP_4085 |chr19 |  15880938|  15881155|Psat1         |-           |           66181|ENSMUSG00000024640.9  |
|ChIP_7904 |chr8  |  57722075|  57722384|Galnt7        |-           |           69042|ENSMUSG00000031608.13 |
|ChIP_7385 |chr7  |  66294591|  66294737|Gm10974       |+           |           71167|ENSMUSG00000078677.1  |
|ChIP_4426 |chr2  |  18473490|  18473750|Dnajc1        |-           |           80659|ENSMUSG00000026740.12 |
|ChIP_6646 |chr6  |   6496823|   6497053|Sem1          |-           |           81609|ENSMUSG00000042541.10 |
|ChIP_418  |chr1  | 163171807| 163172068|Mroh9         |-           |           86136|ENSMUSG00000071890.4  |
|ChIP_6245 |chr5  |  67011999|  67012331|Phox2b        |-           |           86969|ENSMUSG00000012520.10 |
|ChIP_6991 |chr6  |  92609775|  92609973|Prickle2      |-           |           96181|ENSMUSG00000030020.13 |
|ChIP_6990 |chr6  |  92609037|  92609322|Prickle2      |-           |           96832|ENSMUSG00000030020.13 |
|ChIP_131  |chr1  |  61539990|  61540311|Pard3b        |+           |           98512|ENSMUSG00000052062.14 |
|ChIP_7797 |chr8  |  23511208|  23511335|Sfrp1         |+           |           99705|ENSMUSG00000031548.7  |
|ChIP_7840 |chr8  |  34255001|  34255257|Saraf         |+           |          100437|ENSMUSG00000031532.7  |
|ChIP_1607 |chr12 |  70553852|  70554150|Tmx1          |+           |          100756|ENSMUSG00000021072.12 |
|ChIP_3754 |chr18 |   4523021|   4523422|Jcad          |+           |          111455|ENSMUSG00000033960.6  |
|ChIP_733  |chr10 |  63541746|  63542097|Ctnna3        |+           |          111647|ENSMUSG00000060843.11 |
|ChIP_4116 |chr19 |  21890331|  21890659|Cemip2        |+           |          111988|ENSMUSG00000024754.13 |
|ChIP_897  |chr10 | 108896662| 108896833|Syt1          |-           |          114148|ENSMUSG00000035864.14 |
|ChIP_6891 |chr6  |  73587693|  73588028|4931417E11Rik |-           |          118025|ENSMUSG00000056197.6  |
|ChIP_1456 |chr12 |   9688865|   9689094|Osr1          |+           |          118748|ENSMUSG00000048387.8  |
|ChIP_1457 |chr12 |   9689550|   9689802|Osr1          |+           |          119433|ENSMUSG00000048387.8  |
|ChIP_3554 |chr17 |  44653247|  44653475|Supt3         |+           |          123676|ENSMUSG00000038954.14 |
|ChIP_7850 |chr8  |  35968294|  35968679|Prag1         |+           |          126148|ENSMUSG00000050271.12 |
|ChIP_1560 |chr12 |  36510004|  36510274|Crppa         |+           |          128553|ENSMUSG00000043153.6  |
|ChIP_2899 |chr15 |  96830114|  96830416|Slc38a2       |-           |          130383|ENSMUSG00000022462.7  |
|ChIP_2223 |chr13 | 118800239| 118800464|Fgf10         |+           |          130447|ENSMUSG00000021732.14 |
|ChIP_4871 |chr2  | 131723272| 131723554|Erv3          |-           |          136192|ENSMUSG00000037482.2  |
|ChIP_2682 |chr15 |  58685093|  58685450|Tmem65        |-           |          138187|ENSMUSG00000062373.8  |
|ChIP_4105 |chr19 |  21106236|  21106475|Tmc1          |-           |          152033|ENSMUSG00000024749.9  |
|ChIP_39   |chr1  |  35914352|  35914676|Hs6st1        |+           |          153723|ENSMUSG00000045216.7  |
|ChIP_5214 |chr3  |  54517630|  54517906|Postn         |+           |          156520|ENSMUSG00000027750.16 |
|ChIP_8007 |chr8  |  87043949|  87044116|N4bp1         |-           |          158690|ENSMUSG00000031652.11 |
|ChIP_5181 |chr3  |  38322433|  38322635|Ankrd50       |-           |          162208|ENSMUSG00000044864.16 |
|ChIP_4199 |chr19 |  33355314|  33355504|Lipo4         |-           |          162275|ENSMUSG00000079344.11 |
|ChIP_6313 |chr5  |  92882221|  92882469|Sowahb        |-           |          162552|ENSMUSG00000045314.5  |
|ChIP_4422 |chr2  |  14768235|  14768440|Cacnb2        |+           |          165146|ENSMUSG00000057914.15 |
|ChIP_8154 |chr8  | 121376502| 121376819|1700018B08Rik |-           |          167500|ENSMUSG00000031809.10 |
|ChIP_5479 |chr3  | 131911318| 131911658|Dkk2          |+           |          173633|ENSMUSG00000028031.6  |
|ChIP_4909 |chr2  | 139891787| 139892002|Tasp1         |-           |          174802|ENSMUSG00000039033.11 |
|ChIP_6294 |chr5  |  89278424|  89278640|Gc            |-           |          179257|ENSMUSG00000035540.12 |
|ChIP_2165 |chr13 | 103589716| 103589941|Srek1         |-           |          184666|ENSMUSG00000032621.8  |
|ChIP_7835 |chr8  |  33199371|  33199538|Wrn           |-           |          185988|ENSMUSG00000031583.13 |
|ChIP_8288 |chr9  |  32835186|  32835535|Ets1          |+           |          198964|ENSMUSG00000032035.16 |
|ChIP_1853 |chr13 |  15804081|  15804293|Inhba         |+           |          207557|ENSMUSG00000041324.14 |
|ChIP_2089 |chr13 |  81094650|  81094815|Arrdc3        |+           |          211265|ENSMUSG00000074794.10 |
|ChIP_1905 |chr13 |  32553209|  32553497|Gmds          |-           |          214468|ENSMUSG00000038372.14 |
|ChIP_4178 |chr19 |  31531308|  31531802|Prkg1         |-           |          233230|ENSMUSG00000052920.16 |
|ChIP_3751 |chr17 |  89450637|  89451055|Fshr          |-           |          249961|ENSMUSG00000032937.5  |
|ChIP_2602 |chr15 |  42128981|  42129329|Abra          |-           |          259260|ENSMUSG00000042895.6  |
|ChIP_8289 |chr9  |  32899917|  32900187|Ets1          |+           |          263695|ENSMUSG00000032035.16 |
|ChIP_1719 |chr12 |  95420980|  95421284|Flrt2         |+           |          270941|ENSMUSG00000047414.6  |
|ChIP_1874 |chr13 |  29575912|  29576508|Cdkal1        |-           |          279165|ENSMUSG00000006191.17 |
|ChIP_1040 |chr11 |  40402608|  40402839|Mat2b         |-           |          292363|ENSMUSG00000042032.13 |
|ChIP_5290 |chr3  |  80501191|  80501432|Gria2         |-           |          301402|ENSMUSG00000033981.14 |
|ChIP_4590 |chr2  |  50833806|  50834160|Rnd3          |-           |          314950|ENSMUSG00000017144.8  |
|ChIP_1551 |chr12 |  34327620|  34327811|Twist1        |+           |          369948|ENSMUSG00000035799.6  |
|ChIP_5531 |chr3  | 148595648| 148595876|Adgrl2        |-           |          394678|ENSMUSG00000028184.12 |
|ChIP_5461 |chr3  | 127099897| 127100103|Ank2          |-           |          399246|ENSMUSG00000032826.19 |
|ChIP_8061 |chr8  | 103698971| 103699453|Cdh5          |+           |          402171|ENSMUSG00000031871.9  |
|ChIP_5135 |chr3  |  21669742|  21670078|Tbl1xr1       |+           |          406573|ENSMUSG00000027630.13 |
|ChIP_8768 |chrX  |  90340376|  90340547|4930415L06Rik |-           |          407523|ENSMUSG00000035387.5  |
|ChIP_1978 |chr13 |  47561325|  47561718|Rnf144b       |+           |          438668|ENSMUSG00000038068.15 |
|ChIP_5750 |chr4  |  85974465|  85974747|Adamtsl1      |+           |          460292|ENSMUSG00000066113.16 |
|ChIP_2082 |chr13 |  78697953|  78698196|Nr2f1         |-           |          498195|ENSMUSG00000069171.14 |
|ChIP_2069 |chr13 |  71376388|  71376587|Adamts16      |-           |          534576|ENSMUSG00000049538.14 |
|ChIP_2070 |chr13 |  71377500|  71377758|Adamts16      |-           |          535688|ENSMUSG00000049538.14 |
|ChIP_7221 |chr6  | 143916834| 143917032|Etnk1         |+           |          749612|ENSMUSG00000030275.6  |
|ChIP_4395 |chr2  |   8660455|   8660846|Celf2         |-           |         1150891|ENSMUSG00000002107.18 |
|ChIP_574  |chr10 |  16139294|  16139467|Gje1          |-           |         1421079|ENSMUSG00000019867.4  |


:::
:::

### Normal Chow Diet


::: {.cell}

```{.r .cell-code}
# Find closest TSS for each ChIP peak
ncd.nearest_tss_idx   <- nearest(ncd.chip_peaks_that_overlap_ATAC, tss)
ncd.distance_to_tss   <- distance(ncd.chip_peaks_that_overlap_ATAC, tss[ncd.nearest_tss_idx])

# Build the final annotation table
ncd.annotation <- data.frame(
  peak_id         = names(ncd.chip_peaks_that_overlap_ATAC),
  chr             = seqnames(ncd.chip_peaks_that_overlap_ATAC),
  start           = start(ncd.chip_peaks_that_overlap_ATAC),
  end             = end(ncd.chip_peaks_that_overlap_ATAC),
  nearest_gene    = names(tss)[ncd.nearest_tss_idx],
  gene_strand     = as.character(strand(tss[ncd.nearest_tss_idx])),
  distance_to_TSS = ncd.distance_to_tss,
  gene_id         = genes$gene_id[ncd.nearest_tss_idx],
  stringsAsFactors = FALSE
) %>% arrange(ncd.distance_to_tss)

library(knitr)
kable(ncd.annotation,caption="ChIP peaks overlapping NCD-specific ATAC peaks and their nearest genes")
```

::: {.cell-output-display}


Table: ChIP peaks overlapping NCD-specific ATAC peaks and their nearest genes

|peak_id   |chr   |     start|       end|nearest_gene  |gene_strand | distance_to_TSS|gene_id               |
|:---------|:-----|---------:|---------:|:-------------|:-----------|---------------:|:---------------------|
|ChIP_2929 |chr15 |  99875139|  99875679|Lima1         |-           |               0|ENSMUSG00000023022.14 |
|ChIP_6298 |chr5  |  90640673|  90641234|Rassf6        |-           |              15|ENSMUSG00000029370.10 |
|ChIP_2135 |chr13 | 101768313| 101768545|Pik3r1        |-           |              95|ENSMUSG00000041417.15 |
|ChIP_6432 |chr5  | 114145906| 114146392|Acacb         |+           |             142|ENSMUSG00000042010.16 |
|ChIP_4018 |chr19 |   4497640|   4498000|2010003K11Rik |-           |             582|ENSMUSG00000042041.7  |
|ChIP_7488 |chr7  |  97418832|  97419134|Thrsp         |-           |            1101|ENSMUSG00000035686.8  |
|ChIP_1102 |chr11 |  60044760|  60045178|Pemt          |-           |            1310|ENSMUSG00000000301.16 |
|ChIP_425  |chr1  | 164798502| 164798806|Dpt           |+           |            1857|ENSMUSG00000026574.5  |
|ChIP_1414 |chr11 | 120798322| 120798533|Dus1l         |-           |            1918|ENSMUSG00000025155.15 |
|ChIP_7160 |chr6  | 125234528| 125234710|Cd27          |-           |            2299|ENSMUSG00000030336.14 |
|ChIP_7489 |chr7  |  97420367|  97420739|Thrsp         |-           |            2636|ENSMUSG00000035686.8  |
|ChIP_1415 |chr11 | 120821192| 120821407|Fasn          |-           |            3139|ENSMUSG00000025153.9  |
|ChIP_7490 |chr7  |  97420927|  97421392|Thrsp         |-           |            3196|ENSMUSG00000035686.8  |
|ChIP_7491 |chr7  |  97421687|  97422177|Thrsp         |-           |            3956|ENSMUSG00000035686.8  |
|ChIP_4322 |chr19 |  55122557|  55122740|Gpam          |-           |            4497|ENSMUSG00000024978.11 |
|ChIP_4019 |chr19 |   4515310|   4515663|Pcx           |+           |            4837|ENSMUSG00000024892.17 |
|ChIP_4498 |chr2  |  32255025|  32255175|Uck1          |-           |            4983|ENSMUSG00000002550.16 |
|ChIP_4017 |chr19 |   4492875|   4493334|2010003K11Rik |-           |            5248|ENSMUSG00000042041.7  |
|ChIP_4959 |chr2  | 152741579| 152742163|Id1           |+           |            5327|ENSMUSG00000042745.9  |
|ChIP_4016 |chr19 |   4492630|   4492824|2010003K11Rik |-           |            5758|ENSMUSG00000042041.7  |
|ChIP_3904 |chr18 |  60495244|  60495969|Smim3         |-           |            6017|ENSMUSG00000038059.7  |
|ChIP_1416 |chr11 | 120830593| 120831090|Fasn          |-           |            6045|ENSMUSG00000025153.9  |
|ChIP_662  |chr10 |  40333071|  40333469|Cdk19         |+           |            6094|ENSMUSG00000038481.13 |
|ChIP_414  |chr1  | 162891968| 162892452|Fmo2          |-           |            6273|ENSMUSG00000040170.13 |
|ChIP_946  |chr11 |   3921175|   3921494|Slc35e4       |-           |            6510|ENSMUSG00000048807.2  |
|ChIP_4497 |chr2  |  32252632|  32253048|Uck1          |-           |            7110|ENSMUSG00000002550.16 |
|ChIP_8188 |chr8  | 124583863| 124584405|Capn9         |+           |            7751|ENSMUSG00000031981.7  |
|ChIP_945  |chr11 |   3903109|   3903715|Dusp18        |+           |            7868|ENSMUSG00000047205.12 |
|ChIP_1303 |chr11 | 100553941| 100554212|Ttc25         |+           |            8333|ENSMUSG00000006784.14 |
|ChIP_4261 |chr19 |  44416233|  44416685|Scd1          |-           |            8353|ENSMUSG00000037071.3  |
|ChIP_455  |chr1  | 173622311| 173622559|Ifi209        |+           |            8357|ENSMUSG00000043263.13 |
|ChIP_4854 |chr2  | 130003703| 130003981|Tgm3          |+           |            8367|ENSMUSG00000027401.9  |
|ChIP_8189 |chr8  | 124584679| 124584952|Capn9         |+           |            8567|ENSMUSG00000031981.7  |
|ChIP_7620 |chr7  | 125500600| 125500880|Nsmce1        |-           |            9003|ENSMUSG00000030750.13 |
|ChIP_2398 |chr14 |  63934050|  63934299|Sox7          |+           |            9373|ENSMUSG00000063060.6  |
|ChIP_8190 |chr8  | 124585905| 124586495|Capn9         |+           |            9793|ENSMUSG00000031981.7  |
|ChIP_8136 |chr8  | 120002380| 120002664|Crispld2      |+           |            9941|ENSMUSG00000031825.16 |
|ChIP_8458 |chr9  |  62526567|  62526987|Coro2b        |-           |           10056|ENSMUSG00000041729.15 |
|ChIP_2844 |chr15 |  84133441|  84133922|Pnpla5        |-           |           10265|ENSMUSG00000018868.4  |
|ChIP_6433 |chr5  | 114157270| 114157598|Acacb         |+           |           10734|ENSMUSG00000042010.16 |
|ChIP_2847 |chr15 |  84312949|  84313225|Parvg         |+           |           10800|ENSMUSG00000022439.9  |
|ChIP_6845 |chr6  |  55463076|  55463403|Adcyap1r1     |+           |           11097|ENSMUSG00000029778.12 |
|ChIP_661  |chr10 |  40327950|  40328446|Cdk19         |+           |           11117|ENSMUSG00000038481.13 |
|ChIP_8137 |chr8  | 120004259| 120004723|Crispld2      |+           |           11820|ENSMUSG00000031825.16 |
|ChIP_4323 |chr19 |  55139242|  55139780|Gpam          |-           |           12003|ENSMUSG00000024978.11 |
|ChIP_3657 |chr17 |  73962437|  73963124|Xdh           |-           |           12240|ENSMUSG00000024066.9  |
|ChIP_8191 |chr8  | 124589488| 124589766|Capn9         |+           |           13376|ENSMUSG00000031981.7  |
|ChIP_4262 |chr19 |  44422136|  44422998|Scd1          |-           |           14256|ENSMUSG00000037071.3  |
|ChIP_3766 |chr18 |   5320202|   5320414|Zfp438        |-           |           14392|ENSMUSG00000050945.8  |
|ChIP_454  |chr1  | 173550791| 173550990|Ifi214        |-           |           14833|ENSMUSG00000070501.14 |
|ChIP_6434 |chr5  | 114161616| 114161829|Acacb         |+           |           15080|ENSMUSG00000042010.16 |
|ChIP_4024 |chr19 |   4599360|   4599579|Lrfn4         |-           |           16087|ENSMUSG00000045045.7  |
|ChIP_2845 |chr15 |  84139838|  84140045|Pnpla5        |-           |           16662|ENSMUSG00000018868.4  |
|ChIP_8081 |chr8  | 106185671| 106186033|Slc7a6        |+           |           16813|ENSMUSG00000031904.5  |
|ChIP_6846 |chr6  |  55469155|  55469644|Adcyap1r1     |+           |           17176|ENSMUSG00000029778.12 |
|ChIP_4023 |chr19 |   4597863|   4598135|Lrfn4         |-           |           17531|ENSMUSG00000045045.7  |
|ChIP_4260 |chr19 |  44389524|  44389956|Scd1          |-           |           17922|ENSMUSG00000037071.3  |
|ChIP_4259 |chr19 |  44388748|  44389345|Scd1          |-           |           18533|ENSMUSG00000037071.3  |
|ChIP_6999 |chr6  |  92850194|  92850767|Gm15737       |+           |           18589|ENSMUSG00000079462.1  |
|ChIP_8684 |chrX  |  10734532|  10734833|Mid1ip1       |+           |           19518|ENSMUSG00000008035.12 |
|ChIP_6550 |chr5  | 136226408| 136226944|Sh2b2         |-           |           19611|ENSMUSG00000005057.13 |
|ChIP_8082 |chr8  | 106191087| 106191287|Slc7a6os      |-           |           19647|ENSMUSG00000033106.6  |
|ChIP_6429 |chr5  | 113670154| 113670356|Cmklr1        |-           |           19727|ENSMUSG00000042190.12 |
|ChIP_7702 |chr7  | 140717693| 140717966|Olfr541       |+           |           20425|ENSMUSG00000057997.6  |
|ChIP_4794 |chr2  | 118500385| 118500643|Srp14         |-           |           20673|ENSMUSG00000009549.14 |
|ChIP_3568 |chr17 |  46053321|  46053874|Vegfa         |-           |           20951|ENSMUSG00000023951.18 |
|ChIP_2531 |chr15 |   8689426|   8689660|Slc1a3        |-           |           21103|ENSMUSG00000005360.14 |
|ChIP_8076 |chr8  | 105729315| 105729499|Enkd1         |-           |           21104|ENSMUSG00000013155.10 |
|ChIP_4022 |chr19 |   4593751|   4594144|Lrfn4         |-           |           21522|ENSMUSG00000045045.7  |
|ChIP_6549 |chr5  | 136224398| 136224942|Sh2b2         |-           |           21613|ENSMUSG00000005057.13 |
|ChIP_6430 |chr5  | 113672462| 113673134|Cmklr1        |-           |           22035|ENSMUSG00000042190.12 |
|ChIP_8822 |chrX  | 160412866| 160413207|Adgrg2        |+           |           22175|ENSMUSG00000031298.15 |
|ChIP_7771 |chr8  |  13517285|  13517988|Gas6          |-           |           22794|ENSMUSG00000031451.6  |
|ChIP_5400 |chr3  | 106505240| 106505531|Dennd2d       |+           |           22834|ENSMUSG00000027901.12 |
|ChIP_8823 |chrX  | 160413868| 160414280|Adgrg2        |+           |           23177|ENSMUSG00000031298.15 |
|ChIP_526  |chr1  | 193232505| 193232733|Lamb3         |+           |           24805|ENSMUSG00000026639.18 |
|ChIP_6610 |chr5  | 149020375| 149020730|Gm42791       |-           |           25227|ENSMUSG00000106892.1  |
|ChIP_8426 |chr9  |  58092906|  58093301|Ccdc33        |-           |           25521|ENSMUSG00000037716.15 |
|ChIP_1043 |chr11 |  43927224|  43927448|Adra1b        |-           |           26013|ENSMUSG00000050541.14 |
|ChIP_1194 |chr11 |  77814069|  77814260|Gm10277       |-           |           26321|ENSMUSG00000069804.2  |
|ChIP_4021 |chr19 |   4588615|   4588916|Lrfn4         |-           |           26750|ENSMUSG00000045045.7  |
|ChIP_7772 |chr8  |  13521450|  13521826|Gas6          |-           |           26959|ENSMUSG00000031451.6  |
|ChIP_1138 |chr11 |  67667735|  67668059|Rcvrn         |+           |           27266|ENSMUSG00000020907.1  |
|ChIP_2827 |chr15 |  81774561|  81774965|Tef           |+           |           27455|ENSMUSG00000022389.15 |
|ChIP_2530 |chr15 |   8682906|   8683227|Slc1a3        |-           |           27536|ENSMUSG00000005360.14 |
|ChIP_1044 |chr11 |  43929157|  43929450|Adra1b        |-           |           27946|ENSMUSG00000050541.14 |
|ChIP_3897 |chr18 |  56735956|  56736251|Lmnb1         |+           |           28142|ENSMUSG00000024590.8  |
|ChIP_2421 |chr14 |  67101009|  67101303|Ppp2r2a       |-           |           28564|ENSMUSG00000022052.9  |
|ChIP_8810 |chrX  | 143365347| 143365501|Chrdl1        |-           |           28760|ENSMUSG00000031283.16 |
|ChIP_7966 |chr8  |  77487140|  77487422|Arhgap10      |-           |           30530|ENSMUSG00000037148.8  |
|ChIP_4894 |chr2  | 136682121| 136682579|Snap25        |+           |           30873|ENSMUSG00000027273.13 |
|ChIP_7774 |chr8  |  13531205|  13531457|1700029H14Rik |-           |           31003|ENSMUSG00000031452.15 |
|ChIP_7773 |chr8  |  13529098|  13530368|1700029H14Rik |-           |           32092|ENSMUSG00000031452.15 |
|ChIP_3569 |chr17 |  46064885|  46065205|Vegfa         |-           |           32515|ENSMUSG00000023951.18 |
|ChIP_6435 |chr5  | 114179586| 114180008|Acacb         |+           |           33050|ENSMUSG00000042010.16 |
|ChIP_6436 |chr5  | 114180425| 114180562|Acacb         |+           |           33889|ENSMUSG00000042010.16 |
|ChIP_4893 |chr2  | 136678616| 136678909|Snap25        |+           |           34543|ENSMUSG00000027273.13 |
|ChIP_6764 |chr6  |  39241525|  39241772|Kdm7a         |-           |           34735|ENSMUSG00000042599.8  |
|ChIP_1546 |chr12 |  33057541|  33057830|Cdhr3         |-           |           35044|ENSMUSG00000035860.9  |
|ChIP_6765 |chr6  |  39242980|  39243291|Kdm7a         |-           |           36190|ENSMUSG00000042599.8  |
|ChIP_287  |chr1  | 133871509| 133871776|Optc          |-           |           36222|ENSMUSG00000010311.15 |
|ChIP_2040 |chr13 |  59859543|  59860056|Tut7          |-           |           36395|ENSMUSG00000035248.9  |
|ChIP_4020 |chr19 |   4578819|   4579118|Lrfn4         |-           |           36548|ENSMUSG00000045045.7  |
|ChIP_6766 |chr6  |  39243498|  39243902|Kdm7a         |-           |           36708|ENSMUSG00000042599.8  |
|ChIP_2846 |chr15 |  84269280|  84269650|Parvb         |+           |           37236|ENSMUSG00000022438.6  |
|ChIP_528  |chr1  | 193310785| 193311147|G0s2          |-           |           37567|ENSMUSG00000009633.3  |
|ChIP_7503 |chr7  |  99419526|  99419732|Gdpd5         |+           |           38111|ENSMUSG00000035314.10 |
|ChIP_529  |chr1  | 193311660| 193311904|G0s2          |-           |           38442|ENSMUSG00000009633.3  |
|ChIP_2134 |chr13 | 101728455| 101728630|Pik3r1        |-           |           39586|ENSMUSG00000041417.15 |
|ChIP_5039 |chr2  | 165938612| 165938788|Zmynd8        |-           |           39595|ENSMUSG00000039671.18 |
|ChIP_4450 |chr2  |  27207111|  27207566|Sardh         |-           |           40770|ENSMUSG00000009614.16 |
|ChIP_530  |chr1  | 193316009| 193316319|G0s2          |-           |           42791|ENSMUSG00000009633.3  |
|ChIP_525  |chr1  | 193086503| 193086909|Utp25         |-           |           43362|ENSMUSG00000016181.9  |
|ChIP_2136 |chr13 | 101811854| 101812355|Pik3r1        |-           |           43636|ENSMUSG00000041417.15 |
|ChIP_3925 |chr18 |  62135919|  62136093|Adrb2         |-           |           43865|ENSMUSG00000045730.4  |
|ChIP_2529 |chr15 |   8665977|   8666324|Slc1a3        |-           |           44439|ENSMUSG00000005360.14 |
|ChIP_531  |chr1  | 193323687| 193324071|Camk1g        |-           |           46226|ENSMUSG00000016179.11 |
|ChIP_6175 |chr5  |  36544839|  36545231|Tbc1d14       |-           |           48044|ENSMUSG00000029192.17 |
|ChIP_2133 |chr13 | 101719350| 101719710|Pik3r1        |-           |           48506|ENSMUSG00000041417.15 |
|ChIP_1418 |chr11 | 120884009| 120884351|Ccdc57        |-           |           48520|ENSMUSG00000048445.6  |
|ChIP_1417 |chr11 | 120883699| 120883967|Ccdc57        |-           |           48904|ENSMUSG00000048445.6  |
|ChIP_8138 |chr8  | 120042745| 120043209|Crispld2      |+           |           50306|ENSMUSG00000031825.16 |
|ChIP_8215 |chr8  | 126895006| 126895523|Tomm20        |-           |           50320|ENSMUSG00000093904.2  |
|ChIP_8139 |chr8  | 120043798| 120044207|Crispld2      |+           |           51359|ENSMUSG00000031825.16 |
|ChIP_6809 |chr6  |  52063972|  52064271|Skap2         |-           |           51422|ENSMUSG00000059182.7  |
|ChIP_6810 |chr6  |  52064309|  52064639|Skap2         |-           |           51759|ENSMUSG00000059182.7  |
|ChIP_2528 |chr15 |   8658353|   8658581|Slc1a3        |-           |           52182|ENSMUSG00000005360.14 |
|ChIP_3128 |chr16 |  32555571|  32555850|Tfrc          |+           |           53069|ENSMUSG00000022797.16 |
|ChIP_7892 |chr8  |  47768747|  47768996|Cldn24        |+           |           53146|ENSMUSG00000061974.2  |
|ChIP_1197 |chr11 |  79039670|  79039858|Lgals9        |-           |           54723|ENSMUSG00000001123.15 |
|ChIP_6811 |chr6  |  52067338|  52067714|Skap2         |-           |           54788|ENSMUSG00000059182.7  |
|ChIP_1059 |chr11 |  45795786|  45796243|Clint1        |+           |           55720|ENSMUSG00000006169.20 |
|ChIP_1994 |chr13 |  51906149|  51906391|Gadd45g       |+           |           59470|ENSMUSG00000021453.2  |
|ChIP_2961 |chr15 | 103627042| 103627572|Glycam1       |-           |           61960|ENSMUSG00000022491.5  |
|ChIP_1521 |chr12 |  32123727|  32123951|Prkar2b       |-           |           62430|ENSMUSG00000002997.15 |
|ChIP_2202 |chr13 | 112529909| 112530084|Il31ra        |-           |           64275|ENSMUSG00000050377.8  |
|ChIP_561  |chr10 |   8951212|   8951792|Sash1         |-           |           65141|ENSMUSG00000015305.6  |
|ChIP_2518 |chr15 |   3648704|   3649094|Ghr           |-           |           65211|ENSMUSG00000055737.12 |
|ChIP_4898 |chr2  | 137049966| 137050304|Jag1          |-           |           66339|ENSMUSG00000027276.7  |
|ChIP_4942 |chr2  | 148510356| 148510984|Cd93          |-           |           66792|ENSMUSG00000027435.8  |
|ChIP_3507 |chr17 |  31788299|  31788677|Sik1          |-           |           67126|ENSMUSG00000024042.7  |
|ChIP_1974 |chr13 |  47190004|  47190362|Rnf144b       |+           |           67347|ENSMUSG00000038068.15 |
|ChIP_2157 |chr13 | 102625217| 102625899|Cd180         |+           |           67658|ENSMUSG00000021624.9  |
|ChIP_3560 |chr17 |  45364769|  45365081|Cdc5l         |-           |           68655|ENSMUSG00000023932.9  |
|ChIP_2132 |chr13 | 101697995| 101698286|Pik3r1        |-           |           69930|ENSMUSG00000041417.15 |
|ChIP_2532 |chr15 |   8781243|   8781509|Slc1a3        |-           |           70478|ENSMUSG00000005360.14 |
|ChIP_3743 |chr17 |  87353875|  87354123|Ttc7          |+           |           70988|ENSMUSG00000036918.16 |
|ChIP_999  |chr11 |  22438674|  22438950|Tmem17        |+           |           73137|ENSMUSG00000049904.7  |
|ChIP_179  |chr1  |  82159177|  82159496|Gm9747        |+           |           73615|ENSMUSG00000022591.5  |
|ChIP_3286 |chr16 |  87278434|  87278954|N6amt1        |+           |           75230|ENSMUSG00000044442.11 |
|ChIP_1975 |chr13 |  47200002|  47200349|Rnf144b       |+           |           77345|ENSMUSG00000038068.15 |
|ChIP_7115 |chr6  | 116072891| 116073324|Plxnd1        |-           |           77885|ENSMUSG00000030123.15 |
|ChIP_8523 |chr9  |  77838676|  77839114|Elovl5        |+           |           78249|ENSMUSG00000032349.13 |
|ChIP_3807 |chr18 |  12861710|  12862111|Osbpl1a       |-           |           79729|ENSMUSG00000044252.18 |
|ChIP_1995 |chr13 |  51930156|  51930744|Gadd45g       |+           |           83477|ENSMUSG00000021453.2  |
|ChIP_4336 |chr19 |  56202882|  56203080|Habp2         |+           |           84056|ENSMUSG00000025075.14 |
|ChIP_5677 |chr4  |  56654422|  56654736|Gm26657       |+           |           85333|ENSMUSG00000096930.1  |
|ChIP_5676 |chr4  |  56653089|  56653306|Gm26657       |+           |           86763|ENSMUSG00000096930.1  |
|ChIP_1632 |chr12 |  77049043|  77049217|Max           |-           |           86841|ENSMUSG00000059436.13 |
|ChIP_8783 |chrX  | 101983666| 101984060|Rtl5          |-           |           87243|ENSMUSG00000049191.12 |
|ChIP_1922 |chr13 |  36959025|  36959345|F13a1         |-           |           90898|ENSMUSG00000039109.16 |
|ChIP_7243 |chr6  | 147954973| 147955286|Far2          |+           |           91972|ENSMUSG00000030303.15 |
|ChIP_8278 |chr9  |  30829243|  30830073|Adamts15      |-           |           92378|ENSMUSG00000033453.8  |
|ChIP_1976 |chr13 |  47216947|  47217325|Rnf144b       |+           |           94290|ENSMUSG00000038068.15 |
|ChIP_2156 |chr13 | 102599078| 102599236|Cd180         |+           |           94321|ENSMUSG00000021624.9  |
|ChIP_1633 |chr12 |  77061575|  77061965|Max           |-           |           99373|ENSMUSG00000059436.13 |
|ChIP_2155 |chr13 | 102593284| 102594142|Cd180         |+           |           99415|ENSMUSG00000021624.9  |
|ChIP_7978 |chr8  |  82669293|  82669484|Zfp330        |-           |          104675|ENSMUSG00000031711.7  |
|ChIP_2154 |chr13 | 102586285| 102586611|Cd180         |+           |          106946|ENSMUSG00000021624.9  |
|ChIP_8451 |chr9  |  61806016|  61806228|Rplp1         |-           |          108313|ENSMUSG00000007892.8  |
|ChIP_1971 |chr13 |  46165106|  46165341|Stmnd1        |+           |          108379|ENSMUSG00000063529.3  |
|ChIP_1970 |chr13 |  46164639|  46165089|Stmnd1        |+           |          108631|ENSMUSG00000063529.3  |
|ChIP_8277 |chr9  |  30809208|  30809478|Adamts15      |-           |          112973|ENSMUSG00000033453.8  |
|ChIP_8276 |chr9  |  30808905|  30809077|Adamts15      |-           |          113374|ENSMUSG00000033453.8  |
|ChIP_2153 |chr13 | 102578710| 102579228|Cd180         |+           |          114329|ENSMUSG00000021624.9  |
|ChIP_8275 |chr9  |  30806381|  30806609|Adamts15      |-           |          115842|ENSMUSG00000033453.8  |
|ChIP_5825 |chr4  | 106199782| 106200168|Usp24         |+           |          116044|ENSMUSG00000028514.15 |
|ChIP_6729 |chr6  |  32167861|  32168161|1700012A03Rik |+           |          117614|ENSMUSG00000029766.7  |
|ChIP_369  |chr1  | 154080532| 154080845|Zfp648        |+           |          120341|ENSMUSG00000066797.6  |
|ChIP_368  |chr1  | 154076962| 154077398|Zfp648        |+           |          123788|ENSMUSG00000066797.6  |
|ChIP_8167 |chr8  | 122133886| 122134272|Zfp469        |+           |          124347|ENSMUSG00000043903.4  |
|ChIP_3579 |chr17 |  47135548|  47135746|Ubr2          |-           |          124991|ENSMUSG00000023977.15 |
|ChIP_3720 |chr17 |  84320494|  84320918|Zfp36l2       |-           |          132546|ENSMUSG00000045817.8  |
|ChIP_3226 |chr16 |  58273455|  58273648|Dcbld2        |+           |          134794|ENSMUSG00000035107.13 |
|ChIP_367  |chr1  | 154065898| 154066350|Zfp648        |+           |          134836|ENSMUSG00000066797.6  |
|ChIP_3890 |chr18 |  55133716|  55134294|Zfp608        |-           |          141160|ENSMUSG00000052713.9  |
|ChIP_509  |chr1  | 188118141| 188118385|Ush2a         |+           |          143637|ENSMUSG00000026609.15 |
|ChIP_8625 |chr9  | 116324367| 116324643|Tgfbr2        |-           |          149006|ENSMUSG00000032440.13 |
|ChIP_8626 |chr9  | 116324672| 116324956|Tgfbr2        |-           |          149311|ENSMUSG00000032440.13 |
|ChIP_4333 |chr19 |  56135552|  56136094|Habp2         |+           |          151042|ENSMUSG00000025075.14 |
|ChIP_8627 |chr9  | 116328317| 116328557|Tgfbr2        |-           |          152956|ENSMUSG00000032440.13 |
|ChIP_1529 |chr12 |  32661881|  32662435|Nampt         |+           |          157109|ENSMUSG00000020572.8  |
|ChIP_2542 |chr15 |  11746817|  11747230|Npr3          |-           |          160056|ENSMUSG00000022206.7  |
|ChIP_1075 |chr11 |  52602030|  52602394|Fstl4         |+           |          162239|ENSMUSG00000036264.9  |
|ChIP_8009 |chr8  |  87308242|  87308612|Cbln1         |-           |          163996|ENSMUSG00000031654.16 |
|ChIP_5703 |chr4  |  62727808|  62728211|Rgs3          |+           |          167960|ENSMUSG00000059810.18 |
|ChIP_851  |chr10 |  95152543|  95153031|Cradd         |-           |          171101|ENSMUSG00000045867.10 |
|ChIP_850  |chr10 |  95151067|  95151411|Cradd         |-           |          172721|ENSMUSG00000045867.10 |
|ChIP_3224 |chr16 |  57927844|  57928131|Col8a1        |-           |          173106|ENSMUSG00000068196.5  |
|ChIP_3764 |chr18 |   5161103|   5161341|Zfp438        |-           |          173465|ENSMUSG00000050945.8  |
|ChIP_3225 |chr16 |  57928223|  57928919|Col8a1        |-           |          173485|ENSMUSG00000068196.5  |
|ChIP_3763 |chr18 |   5159434|   5159805|Zfp438        |-           |          175001|ENSMUSG00000050945.8  |
|ChIP_6829 |chr6  |  53645013|  53645296|Tril          |-           |          175533|ENSMUSG00000043496.7  |
|ChIP_2106 |chr13 |  90727853|  90728361|Atp6ap1l      |-           |          176993|ENSMUSG00000078958.9  |
|ChIP_3762 |chr18 |   5155940|   5156403|Zfp438        |-           |          178403|ENSMUSG00000050945.8  |
|ChIP_1920 |chr13 |  36302771|  36302965|Lyrm4         |-           |          185244|ENSMUSG00000046573.7  |
|ChIP_5704 |chr4  |  62745984|  62746465|Rgs3          |+           |          186136|ENSMUSG00000059810.18 |
|ChIP_3761 |chr18 |   5141478|   5142102|Zfp438        |-           |          192704|ENSMUSG00000050945.8  |
|ChIP_2260 |chr14 |  22215433|  22215660|Lrmda         |+           |          195720|ENSMUSG00000063458.13 |
|ChIP_6327 |chr5  |  97834707|  97835138|Antxr2        |-           |          195904|ENSMUSG00000029338.13 |
|ChIP_2261 |chr14 |  22215853|  22216258|Lrmda         |+           |          196140|ENSMUSG00000063458.13 |
|ChIP_8546 |chr9  |  85551844|  85552093|Ibtk          |-           |          197240|ENSMUSG00000035941.15 |
|ChIP_5817 |chr4  | 105364490| 105364983|Plpp3         |+           |          207142|ENSMUSG00000028517.8  |
|ChIP_5818 |chr4  | 105365061| 105365464|Plpp3         |+           |          207713|ENSMUSG00000028517.8  |
|ChIP_492  |chr1  | 184519553| 184519957|Hlx           |-           |          212661|ENSMUSG00000039377.7  |
|ChIP_1999 |chr13 |  52060734|  52060944|Gadd45g       |+           |          214055|ENSMUSG00000021453.2  |
|ChIP_8448 |chr9  |  61595500|  61595862|Tle3          |+           |          223133|ENSMUSG00000032280.16 |
|ChIP_8449 |chr9  |  61596826|  61597048|Tle3          |+           |          224459|ENSMUSG00000032280.16 |
|ChIP_5674 |chr4  |  56514721|  56514953|Gm26657       |+           |          225116|ENSMUSG00000096930.1  |
|ChIP_3767 |chr18 |   5818872|   5819171|Zeb1          |+           |          227011|ENSMUSG00000024238.15 |
|ChIP_5673 |chr4  |  56503777|  56504014|Gm26657       |+           |          236055|ENSMUSG00000096930.1  |
|ChIP_5764 |chr4  |  95289109|  95289414|Jun           |-           |          236886|ENSMUSG00000052684.4  |
|ChIP_5765 |chr4  |  95290253|  95290625|Jun           |-           |          238030|ENSMUSG00000052684.4  |
|ChIP_585  |chr10 |  17481534|  17481726|Cited2        |+           |          241491|ENSMUSG00000039910.10 |
|ChIP_584  |chr10 |  17480919|  17481327|Cited2        |+           |          241890|ENSMUSG00000039910.10 |
|ChIP_2131 |chr13 | 101524276| 101524527|Pik3r1        |-           |          243689|ENSMUSG00000041417.15 |
|ChIP_2714 |chr15 |  62229871|  62230257|Myc           |+           |          244479|ENSMUSG00000022346.16 |
|ChIP_5483 |chr3  | 132382240| 132382578|Gimd1         |+           |          247241|ENSMUSG00000091721.4  |
|ChIP_1771 |chr12 | 107752991| 107753484|Bcl11b        |-           |          250117|ENSMUSG00000048251.15 |
|ChIP_7638 |chr7  | 129847181| 129847417|Wdr11         |+           |          255317|ENSMUSG00000042055.13 |
|ChIP_2666 |chr15 |  56952236|  56952540|Has2          |-           |          257696|ENSMUSG00000022367.7  |
|ChIP_2130 |chr13 | 101092450| 101092812|Slc30a5       |-           |          259022|ENSMUSG00000021629.10 |
|ChIP_1962 |chr13 |  44469035|  44469234|Jarid2        |+           |          260239|ENSMUSG00000038518.15 |
|ChIP_5779 |chr4  |  98122556|  98122945|Tm2d1         |-           |          260360|ENSMUSG00000028563.16 |
|ChIP_2667 |chr15 |  56956665|  56957047|Has2          |-           |          262125|ENSMUSG00000022367.7  |
|ChIP_7999 |chr8  |  86301897|  86302113|Abcc12        |-           |          278572|ENSMUSG00000036872.16 |
|ChIP_2145 |chr13 | 102050456| 102050867|Pik3r1        |-           |          282238|ENSMUSG00000041417.15 |
|ChIP_2717 |chr15 |  62269505|  62269863|Myc           |+           |          284113|ENSMUSG00000022346.16 |
|ChIP_7642 |chr7  | 129876162| 129876767|Wdr11         |+           |          284298|ENSMUSG00000042055.13 |
|ChIP_7549 |chr7  | 111370398| 111370836|Eif4g2        |-           |          287367|ENSMUSG00000005610.17 |
|ChIP_5820 |chr4  | 105457217| 105457437|Plpp3         |+           |          299869|ENSMUSG00000028517.8  |
|ChIP_2669 |chr15 |  57172555|  57172949|Slc22a22      |-           |          304675|ENSMUSG00000022366.12 |
|ChIP_2003 |chr13 |  52153627|  52153893|Gadd45g       |+           |          306948|ENSMUSG00000021453.2  |
|ChIP_2004 |chr13 |  52154213|  52154492|Gadd45g       |+           |          307534|ENSMUSG00000021453.2  |
|ChIP_2005 |chr13 |  52155380|  52155859|Gadd45g       |+           |          308701|ENSMUSG00000021453.2  |
|ChIP_2608 |chr15 |  42366829|  42367167|Angpt1        |-           |          309809|ENSMUSG00000022309.9  |
|ChIP_2607 |chr15 |  42365047|  42365284|Angpt1        |-           |          311692|ENSMUSG00000022309.9  |
|ChIP_1961 |chr13 |  44409486|  44409723|Jarid2        |+           |          319750|ENSMUSG00000038518.15 |
|ChIP_7645 |chr7  | 129918852| 129919131|Wdr11         |+           |          326988|ENSMUSG00000042055.13 |
|ChIP_5771 |chr4  |  97439257|  97439593|Nfia          |+           |          333140|ENSMUSG00000028565.18 |
|ChIP_2007 |chr13 |  52188729|  52188995|Gadd45g       |+           |          342050|ENSMUSG00000021453.2  |
|ChIP_5744 |chr4  |  83949704|  83950099|Ccdc171       |+           |          424158|ENSMUSG00000052407.17 |
|ChIP_2151 |chr13 | 102253459| 102254010|Cd180         |+           |          439547|ENSMUSG00000021624.9  |
|ChIP_2631 |chr15 |  51363373|  51363725|Trps1         |-           |          472909|ENSMUSG00000038679.16 |
|ChIP_8133 |chr8  | 118778339| 118778764|Cdh13         |+           |          494605|ENSMUSG00000031841.19 |
|ChIP_2266 |chr14 |  22952153|  22952353|Lrmda         |+           |          932440|ENSMUSG00000063458.13 |
|ChIP_4568 |chr2  |  46371110|  46371313|Zeb2          |-           |         1253714|ENSMUSG00000026872.18 |


:::
:::


## Session Information


::: {.cell}

```{.r .cell-code}
sessionInfo()
```

::: {.cell-output .cell-output-stdout}

```
R version 4.5.2 (2025-10-31)
Platform: aarch64-apple-darwin20
Running under: macOS Tahoe 26.1

Matrix products: default
BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1

locale:
[1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8

time zone: America/Detroit
tzcode source: internal

attached base packages:
[1] stats4    stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] knitr_1.50           rtracklayer_1.68.0   GenomicRanges_1.60.0
 [4] GenomeInfoDb_1.44.3  IRanges_2.42.0       S4Vectors_0.46.0    
 [7] BiocGenerics_0.54.1  generics_0.1.4       readxl_1.4.5        
[10] lubridate_1.9.4      forcats_1.0.1        stringr_1.6.0       
[13] dplyr_1.1.4          purrr_1.2.0          readr_2.1.6         
[16] tidyr_1.3.1          tibble_3.3.0         ggplot2_4.0.1       
[19] tidyverse_2.0.0     

loaded via a namespace (and not attached):
 [1] SummarizedExperiment_1.38.1 gtable_0.3.6               
 [3] rjson_0.2.23                xfun_0.54                  
 [5] htmlwidgets_1.6.4           lattice_0.22-7             
 [7] Biobase_2.68.0              tzdb_0.5.0                 
 [9] vctrs_0.6.5                 tools_4.5.2                
[11] bitops_1.0-9                curl_7.0.0                 
[13] parallel_4.5.2              pkgconfig_2.0.3            
[15] Matrix_1.7-4                RColorBrewer_1.1-3         
[17] S7_0.2.1                    lifecycle_1.0.4            
[19] GenomeInfoDbData_1.2.14     compiler_4.5.2             
[21] farver_2.1.2                Rsamtools_2.24.1           
[23] Biostrings_2.76.0           codetools_0.2-20           
[25] htmltools_0.5.8.1           RCurl_1.98-1.17            
[27] yaml_2.3.10                 pillar_1.11.1              
[29] crayon_1.5.3                BiocParallel_1.42.2        
[31] DelayedArray_0.34.1         abind_1.4-8                
[33] tidyselect_1.2.1            digest_0.6.38              
[35] stringi_1.8.7               restfulr_0.0.16            
[37] fastmap_1.2.0               grid_4.5.2                 
[39] SparseArray_1.8.1           cli_3.6.5                  
[41] magrittr_2.0.4              S4Arrays_1.8.1             
[43] XML_3.99-0.20               withr_3.0.2                
[45] scales_1.4.0                UCSC.utils_1.4.0           
[47] bit64_4.6.0-1               timechange_0.3.0           
[49] rmarkdown_2.30              XVector_0.48.0             
[51] httr_1.4.7                  matrixStats_1.5.0          
[53] bit_4.6.0                   cellranger_1.1.0           
[55] hms_1.1.4                   evaluate_1.0.5             
[57] BiocIO_1.18.0               rlang_1.1.6                
[59] glue_1.8.0                  vroom_1.6.6                
[61] rstudioapi_0.17.1           jsonlite_2.0.0             
[63] R6_2.6.1                    MatrixGenerics_1.20.0      
[65] GenomicAlignments_1.44.0   
```


:::
:::

