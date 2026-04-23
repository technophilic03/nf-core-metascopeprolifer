# Take in arguments from bash script
args <- commandArgs(trailingOnly = TRUE)

readPath1 <- args[1]
readPath2 <- args[2]
indexDir <- args[3]
expTag <- args[4]
outDir <- args[5]
tmpDir <- args[6]
threads <- args[7]
targets <- stringr::str_split(args[8], ",")[[1]]
filters <- stringr::str_split(args[9], ",")[[1]]

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

metascope_id(final_map, input_type = "csv.gz", aligner = "bowtie2",
             accession_path = file.path(loc, "indices", "accessionTaxa.sql"),
             num_species_plot = 15,
             quiet = FALSE,
             out_dir = outDir)

message(capture.output(Sys.time() - now))