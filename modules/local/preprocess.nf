process PREPROCESS {

    tag "$sampleName"

    cpus 8

    publishDir "${params.outdir ?: 'results'}/trimmed", mode: 'copy'

    input:
    tuple val(sampleName), path(read1), path(read2)

    output:
    tuple val(sampleName),
          path("${sampleName}_R1.paired.fastq.gz"),
          path("${sampleName}_R2.paired.fastq.gz")

    script:
    """
    set -euo pipefail

    echo "Trimming reads for ${sampleName}"

    java -jar /home/hf268/f_wj183_1/work/Howard/MetaScope_Nextflow/metascope-nextflow/trimmomatic-0.40.jar PE \
        -phred33 \
        -threads ${task.cpus} \
        ${read1} ${read2} \
        ${sampleName}_R1.paired.fastq.gz \
        ${sampleName}_R1.unpaired.fastq.gz \
        ${sampleName}_R2.paired.fastq.gz \
        ${sampleName}_R2.unpaired.fastq.gz \
        SLIDINGWINDOW:4:20 \
        LEADING:3 \
        TRAILING:3 \
        MINLEN:36 \
        CROP:225 \
        HEADCROP:30
    """
}
