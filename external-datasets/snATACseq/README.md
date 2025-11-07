# Analysis of GSE236575

In this study, Hinte *et al.* used AdipER-Cre/NuTRAP mice to look at HFD for 12 or 25 weeks (controls on ctontrol diet.  eWAT wat isolated and nucliei from labelled adipocytes were used for ATACseq.

First downloaded GSE236575_RAW from [GEO](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE236575) and extracted the bed files that were present.  

Each bed file included FDR 0.01% peaks.  They were grouped into CHD (Chow) or (HFD) based on file names (ignoring the LHFD, LCHD, CC and HC groups).  We focused in on the HFD and CHD groups (mapped to GRCm38 a.k.a. mm10)

## Combining and Sorting BED files

First we combined and sorted the gzipped bed files into one CHD and one HFD bed file

```{bash}
gunzip -c *CHD*_GRCm38_bowtie2.sorted.bam.FDR_0.01.stringent.bed.gz \
  | sort -k1,1 -k2,2n > CHD_all.bed

gunzip -c *HFD*_GRCm38_bowtie2.sorted.bam.FDR_0.01.stringent.bed.gz \
  | sort -k1,1 -k2,2n > HFD_all.bed 
```

Then we merged peaks to figure out which peaks overlapped between both 

```{bash}
bedtools merge -i CHD_all.bed > CHD_merged.bed
bedtools merge -i HFD_all.bed > HFD_merged.bed   
```

We then used the merged peaks to figure out which peaks were specific on NCD or on HFD, or were shared between both groups.

```{bash}
bedtools intersect -v -a CHD_merged.bed -b HFD_merged.bed > CHD_specific.bed
bedtools intersect -v -a HFD_merged.bed -b CHD_merged.bed > HFD_specific.bed
bedtools intersect -a CHD_merged.bed -b HFD_merged.bed > shared_peaks.bed
```
and then removed mitochondrially mapped peaks

```{bash}
grep -v "chrM" HFD_merged_chr.bed > HFD_merged_chr_noMT.bed
grep -v "chrM" CHD_merged_chr.bed > CHD_merged_chr_noMT.bed
grep -v "chrM" shared_peaks_chr.bed > shared_peaks_chr_noMT.bed
```

We then did some editing for mapping purposes removing the chr from each bed file

```{r bash}
sed 's/^chr//' CHD_merged.bed > CHD_merged_nochr.bed
sed 's/^chr//' CHD_merged.bed > CHD_merged_nochr.bed
```

Next we resize all peaks to 500bp around their center

```{bash}
awk 'BEGIN{OFS="\t"} {
    center=int(($2+$3)/2); 
    start=center-250; 
    end=center+250;
    if(start<0) start=0;
    print $1, start, end
}' HFD_merged_chr_noMT.bed > HFD_merged_500bp.bed

awk 'BEGIN{OFS="\t"} {
    center=int(($2+$3)/2); 
    start=center-250; 
    end=center+250;
    if(start<0) start=0;
    print $1, start, end
}' CHD_merged_chr_noMT.bed > CHD_merged_500bp.bed

awk 'BEGIN{OFS="\t"} {
    center=int(($2+$3)/2); 
    start=center-250; 
    end=center+250;
    if(start<0) start=0;
    print $1, start, end
}' CHD_merged_chr_noMT.bed > CHD_merged_500bp.bed
```

Then using mm10 we generated fasta files from thesee bed files

```{bash}
bedtools getfasta -fi mm10.fa -bed HFD_merged_500bp.bed -fo HFD_peaks_500bp.fa
bedtools getfasta -fi mm10.fa -bed CHD_merged_500bp.bed -fo CHD_peaks_500bp.fa
bedtools getfasta -fi mm10.fa -bed shared_peaks_chr_noMT.bed -fo shared_peaks_500bp.fa
```

## Known motif identification by MEME-AME

This was all done on GreatLakes

Then using mm10 we generated fasta files from these trimmed bed files

```{bash}
bedtools getfasta -fi mm10.fa -bed HFD_merged_500bp.bed -fo HFD_peaks_500bp.fa
bedtools getfasta -fi mm10.fa -bed CHD_merged_500bp.bed -fo CHD_peaks_500bp.fa
bedtools getfasta -fi mm10.fa -bed shared_peaks_chr_noMT.bed -fo shared_peaks_500bp.fa
```

This was run on greatlakes using the script `ame.slurm`

```{bash}
#compare HFD vs chow
ame --control CHD_peaks_500bp_masked.fa \
    --oc ame_HFD_vs_CHD \
    --hit-lo-fraction 0.1 \
    --evalue-report-threshold 100 \
    HFD_peaks_500bp_masked.fa \
    JASPAR2024_CORE_vertebrates_non-redundant_pfms_meme.txt

#compare HFD vs shared
ame --control shared_peaks.fa \
    --oc ame_HFD_vs_shared \
    --hit-lo-fraction 0.1 \
    --evalue-report-threshold 100 \
    CHD_peaks_500bp_masked.fa \
    JASPAR2024_CORE_vertebrates_non-redundant_pfms_meme.txt

#compare NCD vs shared
ame --control shared_peaks.fa \
    --oc ame_NCD_vs_shared \
    --hit-lo-fraction 0.1 \
    --evalue-report-threshold 100 \
    CHD_peaks_500bp_masked.fa \
    JASPAR2024_CORE_vertebrates_non-redundant_pfms_meme.txt
```