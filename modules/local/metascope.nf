process METASCOPE {

    tag "$sampleName"
    cpus 8

    publishDir "/projectsp/f_wj183_1/work/Howard/MetaScope_Nextflow/test",
               mode: 'copy'

    input:
    tuple val(sampleName), path(read1), path(read2)

    output:
    path("${sampleName}*")

    script:
    """
    set -euo pipefail

    workingDir="${sampleName}_tmp_miossec"
    mkdir -p ${workingDir}

    indexDir="/projects/f_wj183_1/reflib/2025_reference/bowtie_indices/"
    outDir="/projectsp/f_wj183_1/work/Howard/MetaScope_Nextflow/test"
    tmpDir="\$PWD/${workingDir}"

    taxDB=/projectsp/f_wj183_1/reflib/2025_accession_taxa/accessionTaxa.sql

    target="target_reference"
    filter="filter_reference"

    module load singularity

    singularity exec /projects/f_wj183_1/apps/singularity_images/R_samtools_sl1729.sif \
    Rscript --vanilla --max-ppsize=500000 run_MetaScope.R \
        ${read1} ${read2} ${indexDir} ${sampleName} ${outDir} ${tmpDir} ${task.cpus} \
        ${target} ${filter}

    rm -rf ${workingDir}
    """
}
