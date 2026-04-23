process METASCOPE {

    tag "$meta.id"
    label 'process_high'

    publishDir "${params.outdir}/metascope",
               mode: params.publish_dir_mode

    input:
    tuple val(meta), path(reads)
    val index_dir
    val target
    val filter

    output:
    tuple val(meta), path("${meta.id}*"), emit: results

    script:
    def read1  = reads[0]
    def read2  = reads[1]
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    set -euo pipefail

    workingDir="${prefix}_tmp_metascope"
    mkdir -p \${workingDir}

    tmpDir="\$PWD/\${workingDir}"
    outDir="\$PWD"

    Rscript --vanilla --max-ppsize=500000 run_MetaScope.R \\
        ${read1} ${read2} ${index_dir} ${prefix} \${outDir} \${tmpDir} ${task.cpus} \\
        ${target} ${filter}

    rm -rf \${workingDir}
    """
}
