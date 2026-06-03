# Data provenance — 3D-Chromatin

Raw Hi-C inputs are **not committed** (gitignored; ~0.4–0.9 GB gz per replicate).
The Nextflow pipeline (`../main.nf`) downloads them on the compute node.

## TAD source — GSE95533 (Siersbaek et al. 2017, *Mol Cell*)

3T3-L1 adipogenesis Hi-C time course. PMID 28475876.
GEO: <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE95533>

| Stage | Replicate | GEO sample | File |
|-------|-----------|-----------|------|
| D0 (fibroblast) | Exp1 | GSM2515982 | `GSM2515982_HiC_D0_Exp1.hicup.raw.txt.gz` |
| D0 (fibroblast) | Exp2 | GSM2515983 | `GSM2515983_HiC_D0_Exp2.hicup.raw.txt.gz` |
| **D2 (early diff.)** | **Exp1** | **GSM2515986** | `GSM2515986_HiC_D2_Exp1.hicup.raw.txt.gz` |
| **D2 (early diff.)** | **Exp2** | **GSM2515987** | `GSM2515987_HiC_D2_Exp2.hicup.raw.txt.gz` |

**Genome build: mm9** (lifted to mm10 in the pipeline).
**Format:** HiCUP-filtered read-pair list, 6-col TSV with header
`chr1  coord1  strand1  chr2  coord2  strand2`. The pipeline keeps `chr1/coord1`
and `chr2/coord2`, restricts to canonical chromosomes, and feeds the pair list
to `cooler cload pairs` (which enforces upper-triangular order internally).

### ⚠ No mature-adipocyte Hi-C exists in this series

Standard Hi-C in GSE95533 is only at **D0, 4h, D2**. The later differentiation
timepoints (D4, D7) have ChIP/RNA/PCHi-C but **no standard Hi-C**. **D2 is the
most adipocyte-committed Hi-C available.** TAD boundaries are largely invariant
across adipogenesis (the paper's own finding: promoter loops rewire while domain
structure is broadly stable), so D2 TADs are an acceptable proxy for the coarse
"are HFD peaks in GR-rich TADs?" question. Default `params.stages = ['D2']`; add
`'D0'` for a fibroblast sensitivity contrast.

The PCHi-C (promoter-capture) files are **not** used for TAD calling — capture
biases coverage toward promoters and distorts genome-wide domain structure.

## Reference files (downloaded by the pipeline)

- mm9 chrom sizes: `https://hgdownload.soe.ucsc.edu/goldenPath/mm9/bigZips/mm9.chrom.sizes`
- mm9→mm10 liftOver chain: `https://hgdownload.soe.ucsc.edu/goldenPath/mm9/liftOver/mm9ToMm10.over.chain.gz`

## Inputs reused from sibling sub-projects (not regenerated here)

- `../../snATACseq/GSE236575/results/deseq2/{HFD_specific,CHD_specific,shared}_peaks.bed` — ATAC classes (mm10)
- `../../GR-ChIPseq/results/peaks/**` — GR ChIP consensus / narrowPeak sets (mm10)
- `../../GR-ChIPseq/results/gr_enrichment/gr_bound_composite_peaks.tsv` — 151 motif-validated GR-bound composite HFD peaks (Stage 2/H3)
- `../../snATACseq/GSE236575/results/rnaseq/deseq2/rnaseq_deseq2_results.txt` — TRAP-seq DESeq2 DEGs (Stage 2)
