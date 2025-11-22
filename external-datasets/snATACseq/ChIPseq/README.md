
## ChIPseq datasets for GR in adipocytes

### Singh *et al.,* 2016 

- http://dx.doi.org/10.1002/oby.21251
- No GEO record, or information in supplementary files

### Yu *et al.,* 2010 

- http://dx.doi.org/10.1371/journal.pone.0015188
- BED files in pone.0015188.s001.xls, converted to bed format using `r Generate-bed-files.qmd`
- includes micro-array data for 3T3-L1 adipocytes treated with ethanol or dexamethasone (500 nM for 1h)
- [GSE24105](https://www-ncbi-nlm-nih-gov.proxy.lib.umich.edu/geo/query/acc.cgi?acc=GSE24105)

## Analysis

From HFD/ChipSeq overlapping genes (via GrokAI)

> In adipocytes, high-fat diet dramatically increases glucocorticoid receptor occupancy at loci that actively block adipogenesis and drive adipose fibrosis (Postn, Dkk2, Sfrp1, Twist1, Inhba, Col6a3), repress large families of KRAB-domain zinc-finger proteins (Zfp273/235/772/474/Zfat), and reprogram lipid metabolism (Cyp7a1, Cyp4a10, Lpin2). These HFD-specific GR binding events reveal a maladaptive transcriptional program that limits healthy adipose expansion and promotes the fibro-inflammatory state characteristic of obesity.

| Biological Theme                              | Key Genes from Your List                                                                                         | Functional Role in Adipocytes under HFD + Glucocorticoid Excess                                                                                      |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| **KRAB-ZFP repression** (hallmark GR signature) | Zfp273, Zfp235, Zfp772, Zfp474, Zfat                                                                                     | Direct GR-mediated repression of KRAB-domain zinc-finger proteins; strongest and most specific genomic signature of glucocorticoid action in adipocytes |
| **Anti-adipogenic & pro-fibrotic program**    | Postn, Dkk2, Sfrp1, Twist1, Inhba, Fgf10, Col6a3, Cemip2, Adamtsl1, Adamts16                                      | Blocks adipocyte differentiation, drives dedifferentiation and extracellular-matrix remodeling → adipose fibrosis in obesity                     |
| **Wnt/TGFβ/BMP inhibition**                   | Dkk2, Sfrp1, Inhba (Activin A), Twist1                                                                          | Potent inhibitors of adipogenesis; all strongly induced by excess glucocorticoids in obese adipose tissue                                      |
| **Lipid & cholesterol metabolism reprogramming** | Cyp7a1, Cyp4a10, Lpin2, Osbp, Vldlr, Gc (DBP)                                                                   | Shifts adipocytes toward lipid catabolism and alternative oxidation pathways when triglyceride storage capacity is overwhelmed                     |
| **Inflammation / stress response suppression** | Il1rap, Serpinb6b, Prickle2, Arrdc3                                                                              | GR-mediated dampening of inflammatory signaling in mature adipocytes                                                                   |
| **Cell-cycle & progenitor repression**       | Prim2, Ets1, Psat1, Tasp1, Rnd3                                                                                | Prevents adipocyte precursor proliferation and terminal differentiation under chronic glucocorticoid exposure                                 |

**Overall conclusion**  
These HFD-enriched GR binding sites in adipocytes reveal a highly coherent maladaptive program: GR actively **blocks new fat-cell formation**, **promotes fibrosis**, **represses classic KRAB-ZFP targets**, and **reprograms lipid handling** — collectively explaining why chronic glucocorticoid excess (which rises dramatically on HFD) drives adipose dysfunction and metabolic disease.

Notes, again from AI
* Lazar lab 2022–2024: GR-mediated KRAB-ZFP repression is required for full induction of lipolysis in adipocytes under glucocorticoid excess.
* GR directly induces ATGL and HSL in adipocytes during fasting/obesity (Singh 2024 Cell Metab; Yu 2023 Nat Metab). These promoters are closed in chow but open dramatically on HFD.