# 3D-Chromatin — TAD-level GR/AP-1 integration

A 3D analogue of the `GR-ChIPseq` sub-project. Tests whether HFD-opened AP-1
chromatin in adipocytes resides preferentially in **TADs that contain GR-bound
elements**, and (Stage 2) whether those enhancers loop to HFD-upregulated
GR-target genes.

## Why

- GSE236575: AP-1 (Junb) opens HFD-specific chromatin; predicted AP-1+GR composite
  motifs are enriched there (Fisher OR = 1.28).
- GR-ChIPseq: but *measured* GR occupancy is **depleted** at those HFD-specific
  peaks (eWAT strain-reproducible OR = 0.09) — GR sits on constitutive/closing
  chromatin instead.
- Reconciling hypothesis (**3D**): AP-1-opened enhancers act on GR-mediated
  transcription by **looping to a GR-bound promoter in the same TAD**, not by
  direct co-binding. Stage 1 tests the TAD-level version of that claim.

## Pipeline (`main.nf`) — runs on Great Lakes (SLURM)

Hi-C processing is heavy (ICE balancing) and the inputs are large, so it runs on
the cluster (same pattern as `../GR-ChIPseq`). It produces only the small mm10
TAD BEDs, which are synced back and consumed locally by `tad-analysis.qmd`.

```
GSE95533 HiCUP raw pairs (mm9)
   └─ DOWNLOAD_HIC           per replicate, GEO FTP
   └─ HICUP_TO_PAIRS         6-col TSV → chrom1/pos1/chrom2/pos2, main chroms
   └─ BUILD_COOL             cooler cload + ICE balance + zoomify → <stage>.mcool
   └─ CALL_TADS_INSULATION   cooltools insulation (windows 100/250/500 kb)   ─┐  caller 1
   └─ INSULATION_TO_TADS     boundaries → domains BED (mm9)                    │
   └─ CALL_TADS_HICEXPLORER  hicFindTADs (independent caller)                 ─┘  caller 2 (sensitivity)
   └─ LIFTOVER_TADS          mm9 → mm10 (UCSC liftOver)  → results/tads/*.mm10.bed
```

Hi-C tools (cooler, cooltools, hicexplorer) come from per-process **conda**
environments (`conda.enabled = true`); base tools from the `Bioinformatics`
module. liftOver binary is downloaded on the node (as in GR-ChIPseq).

### Run it

```bash
# on Great Lakes, from this directory
sbatch nextflow.slurm        # tiny orchestrator job; submits each task as its own SLURM job
```

Default processes **D2** only (`params.stages = ['D2']`). To add the D0
fibroblast contrast: `nextflow run main.nf --stages D0,D2 -resume`.

### Sync back

Copy these small files into `results/tads/` locally, then render the qmd:

```
results/tads/D2_insulation_tads.mm10.bed     # primary (cooltools)
results/tads/D2_hicexplorer_tads.mm10.bed    # sensitivity (HiCExplorer)
results/tads/D2_insulation.tsv               # insulation profile (optional, for QC)
```

## Analysis (`tad-analysis.qmd`) — runs locally

Stage 1 enrichment once the TAD BEDs are present:

1. Assign each ATAC peak to its host TAD (by midpoint).
2. Count GR ChIP peaks per TAD (same GR sets as GR-ChIPseq).
3. **Per-peak Fisher + Bayesian OR**: HFD-specific vs shared × GR-rich-TAD,
   plus a width/TAD-length-adjusted logistic.
4. **TAD-level Poisson**: per-TAD GR-peak count ~ HFD-specific-peak count
   (TAD length offset) — the genome-wide 3D claim in one IRR.

Render: `quarto render tad-analysis.qmd`. Until the TAD BEDs are synced, the
report renders a "TAD BED not present yet" notice and skips the analysis blocks.

## Layout

```
3D-Chromatin/
├── main.nf  nextflow.config  nextflow.slurm    # Hi-C → mm10 TAD pipeline (cluster)
├── tad-analysis.qmd                            # Stage 1 enrichment (local)
├── SUMMARY.md                                  # headline results / status
├── data/README.md                             # dataset provenance (raw not committed)
└── results/
    ├── tads/        <stage>_<caller>_tads.mm10.bed   # synced back from cluster
    ├── enrichment/  peak_in_gr_rich_tad.tsv, tad_gr_enrichment.tsv, *_forest.pdf
    ├── abc/         (Stage 2)
    └── figures/     (Stage 3)
```

## Status

Stage 1 pipeline + analysis are built. **Awaiting the Great Lakes run** to
produce the mm10 TAD BEDs and the headline OR. See `SUMMARY.md`.
