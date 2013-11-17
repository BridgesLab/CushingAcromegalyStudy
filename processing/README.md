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

