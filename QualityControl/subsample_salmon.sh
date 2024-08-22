#!/bin/bash

# Initialize variables
INPUT_DIR=""
OUTPUT_DIR=""
PROP=""
GEN_DIR=""
SEED=""

# Function to display usage
usage() {
    echo -e "
sumsample_salmon.sh, a script designed to subsample fastq from RNASeq data and align them using SALMON
Usage:
    subsample_salmon.sh --i <input_dir> --o <output_dir> --p <prop_of_reads> --n <number_of_reads> --g <genome_dir>\n
        folders
        --i: input directory (where the fastq files are)
        --o: output directory (where the produced files will be stored) 
            in this folder, a subsampled & salmon_quant subfolders will be created
        --g: folder where the reference genome is 
            The genome needs to be previously indexed using salmon index\n
        parameters
        --n: number of reads used for subsampling
        --p: proportion of the reads used for subsampling
        --s: seed (seqkit's default, 11)"
    exit 1
}


# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --i) INPUT_DIR="$2"; shift ;;
        --o) OUTPUT_DIR="$2"; shift ;;
        --p) PROP="$2"; shift ;;
        --n) NUM_READS="$2"; shift ;;
        --s) SEED="$2"; shift ;;     # Optional argument for seed
        --g) GEN_DIR="$2"; shift ;;  # Argument for reference genome directory
        --help) usage ;; # Display usage if --help is provided
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if required arguments are provided
if [[ -z "$INPUT_DIR" ]]; then
    echo -e "\nError: Missing input folder\n"
    exit 1
fi

# Check if required arguments are provided
if [[ -z "$OUTPUT_DIR" ]]; then
    echo -e "\nError: Missing output folder\n"
    exit 1
fi

# Check if required arguments are provided
if [[ -z "$GEN_DIR" ]]; then
    echo -e "\nError: Missing genome folder\n"
    exit 1
fi

# Check if the input directory exists
if [[ -n "$INPUT_DIR" && ! -d "$INPUT_DIR" ]]; then
    echo -e "\nError: Input directory '$INPUT_DIR' does not exist.\n"
    exit 1
fi

# Check if there are any FASTQ files in the input directory
if ! ls "$INPUT_DIR"/*.fast* 1> /dev/null 2>&1; then
    echo -e "\nError: No FASTQ files found in the input directory '$INPUT_DIR'.\n"
    exit 1
fi

# Check if the input directory exists
if [[ -n "$OUTPUT_DIR" && ! -d "$OUTPUT_DIR" ]]; then
    echo -e "\nError: Output directory '$OUTPUT_DIR' does not exist.\n"
    exit 1
fi

# Check if the genome directory exists
if [[ -n "$GEN_DIR" && ! -d "$GEN_DIR" ]]; then
    echo -e "\nError: Genome directory '$GEN_DIR' does not exist.\n"
    exit 1
fi

# Create the output directories if they don't exist
mkdir -p "$OUTPUT_DIR/subsampled"
mkdir -p "$OUTPUT_DIR/salmon_quant"

# Loop through all FASTQ files in the input directory
for FASTQ_FILE in "$INPUT_DIR"/*.fast*; do
    if [ -f "$FASTQ_FILE" ]; then

        # Get the base filename without the directory and extension
        filename=$(basename "$FASTQ_FILE")
        modified_name="${filename%%.fastq.gz}"

        # Define the output file for subsampling
        SUBSAMPLED_FILE="$OUTPUT_DIR/subsampled/subsampled_$modified_name.fastq.gz"
        
        if [[ -n "$PROP" ]]; then
            echo -e "\nSubsampling $modified_name - Proportion $PROP\n"
            if [[ -n "$SEED" ]]; then
                seqkit sample -p "$PROP" --seed "$SEED" "$FASTQ_FILE" -o "$SUBSAMPLED_FILE"
            else
                seqkit sample -p "$PROP" "$FASTQ_FILE" -o "$SUBSAMPLED_FILE"
            fi
        elif [[ -n "$NUM_READS" ]]; then
            echo -e "\nSubsampling $modified_name - Number of Reads $NUM_READS\n"
            if [[ -n "$SEED" ]]; then
                seqkit sample -n "$NUM_READS" --seed "$SEED" "$FASTQ_FILE" -o "$SUBSAMPLED_FILE"
            else
                seqkit sample -n "$NUM_READS" "$FASTQ_FILE" -o "$SUBSAMPLED_FILE"
            fi
        fi


    echo -e "\nSaved subsampled file to $SUBSAMPLED_FILE\n"

        # Run Salmon for quantification
        echo -e "\nRunning Salmon on $modified_name\n"
        
        salmon quant \
            -i "$GEN_DIR/Salmon_ENSEMBL_111" \
            -l A \
            -r "$SUBSAMPLED_FILE" \
            -p 20 \
            -o "$OUTPUT_DIR/salmon_quant/${modified_name}_salmon_quant"
        
        echo -e "\nSalmon quantification complete for $modified_name\n"
    fi
done

echo "All processes complete!"