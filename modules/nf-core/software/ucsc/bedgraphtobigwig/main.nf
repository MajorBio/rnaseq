// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

def VERSION = '377'

process UCSC_BEDRAPHTOBIGWIG {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda     (params.enable_conda ? "bioconda::ucsc-bedgraphtobigwig=377" : null)
    container "quay.io/biocontainers/ucsc-bedgraphtobigwig:377--h446ed27_1"

    input:
    tuple val(meta), path(bedgraph)
    path  sizes
    
    output:
    tuple val(meta), path("*.bigWig"), emit: bigwig
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    bedGraphToBigWig $bedgraph $sizes ${prefix}.bigWig
    echo $VERSION > ${software}.version.txt
    """
}
