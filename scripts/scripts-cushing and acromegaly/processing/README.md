Several of these processing steps occured outside of R and were submitted to the MBNI or felix servers.  The code for these external steps are in this folder.  

Sequence Processing and Alignments
-----------------------------------

### Software Versions Used

* Tophat 2.0.6
* Bowtie 2.0.2
* Cufflinks 2.02
* Samtools 0.1.18

### Reference Genome

Used Human Ensembl GRCh37.69 from Ensembl, the GTF file was also downloaded from Ensembl for that version.

The genome sequence was the unmasked toplevel sequence (no patches)

The genome assembly represented here corresponds to GenBank Assembly ID GCA_000001405.9

## Script Order

    ./tophat_cuffinks.sh
    qsub -cwd ./cuffmerge.sh
    qsub -cwd ./cuffdiff_all.sh

Note that cufflinks was run, but not used in this analysis.  The alignment files from the tophat run were used in the counts table generation step.

Counts Table Generation
-------------------------

This was done using the script **counts_table.Rmd**.  This generated a counts table using Rsamtools and genomic ranges.  It includes a non-redundant counts table for every transcript in Ensembl GRCh37.69.  It is later filtered to only show the most abundant transcript.  This script was run externally and the resulting counts table was placed in **transcript_counts_table.csv** and **exon_counts_table.csv**.