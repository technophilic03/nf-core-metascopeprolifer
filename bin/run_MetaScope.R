# Take in arguments from bash script
args <- commandArgs(trailingOnly = TRUE)

readPath1      <- args[1]
readPath2      <- args[2]
indexDir       <- args[3]
expTag         <- args[4]
outDir         <- args[5]
tmpDir         <- args[6]
threads        <- args[7]
targets        <- stringr::str_split(args[8], ",")[[1]]
filters        <- stringr::str_split(args[9], ",")[[1]]
accession_path <- args[10]
db_path        <- args[11]

# Time this!
now <- Sys.time()

# Load MetaScope
library(MetaScope)

# Align to targets
do_this <- function(x) stringr::str_replace_all(x, c(" " = "_"))
targets_ <- do_this(targets) 
filters_ <- do_this(filters)

# Identify bt2 params
data(bt2_regular_params)
bt2_params <- bt2_regular_params

target_map <- align_target_bowtie(read1 = readPath1,
                                  read2 = readPath2,
                                  lib_dir = indexDir,
                                  libs =  targets_,
                                  align_dir = tmpDir,
                                  align_file = expTag,
                                  overwrite = TRUE,
                                  threads = threads,
                                  bowtie2_options = paste(bt2_params, "-f"),
                                  quiet = FALSE)

# Align to filters
output <- paste(paste0(tmpDir, expTag), "filtered", sep = ".")
final_map <- filter_host_bowtie(reads_bam = target_map,
                                lib_dir = indexDir,
                                libs = filters_,
                                make_bam = FALSE,
                                output = output,
                                threads = threads,
                                overwrite = TRUE,
                                quiet = FALSE,
                                bowtie2_options = bt2_params)

# MetaScope ID
metascope_id_path <- metascope_id(
             target_map, input_type = "bam", aligner = "bowtie2",
             accession_path  = accession_path,
             db = "ncbi",
             priors_df = NULL,
             num_species_plot = 0,
             quiet = FALSE,
             out_dir = outDir,
             update_bam = TRUE,
             tmp_dir = tmpDir, 
             force_calls = TRUE)

metascope_blast(metascope_id_path, 
                bam_file_path = list.files(tmpDir, ".updated.bam$",full.names = TRUE)[1], 
                tmp_dir = tmpDir, 
                out_dir = outDir, 
                sample_name = expTag, 
                fasta_dir = NULL,
                num_results = 10, 
                num_reads = 1000, 
                hit_list = 100,
                num_threads = 8, 
                db_path = db_path,
                quiet = FALSE,
                db = "ncbi",
                accession_path = accession_path)

metascope_blast_path <- gsub("metascope_id.csv","metascope_blast.csv", metascope_id_path) 
blast_reassignment(metascope_blast_path, species_threshold = 0.5, num_hits = 100, blast_tmp_dir = paste0(tmpDir, "/blast"), out_dir = outDir, sample_name = expTag)

message(capture.output(Sys.time() - now))