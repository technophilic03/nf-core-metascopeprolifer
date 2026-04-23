process METASCOPE {

    tag "$meta.id"
    label 'process_high'

    publishDir "${params.outdir}/metascope",
               mode: params.publish_dir_mode

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}*"), emit: results

    script:
    def read1 = reads[0]
    def read2 = reads[1]
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    set -euo pipefail

    workingDir="${prefix}_tmp_metascope"
    mkdir -p \${workingDir}

    indexDir="${params.metascope_index_dir}"
    outDir="${params.outdir}/metascope"
    tmpDir="\$PWD/\${workingDir}"
    taxDB="${params.metascope_tax_db}"

    target="${params.metascope_target}"
    filter="${params.metascope_filter}"

    Rscript --vanilla --max-ppsize=500000 run_MetaScope.R \\
        ${read1} ${read2} \${indexDir} ${prefix} \${outDir} \${tmpDir} ${task.cpus} \\
        \${target} \${filter}

    rm -rf \${workingDir}
    """
}
