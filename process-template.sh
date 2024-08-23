#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if all required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <product_name> <input_file> <output_file>"
    exit 1
fi

# Assign arguments to variables
PRODUCT_NAME="$1"
INPUT_FILE="$2"
OUTPUT_FILE="$3"

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found: $INPUT_FILE"
    exit 1
fi

# Replace placeholder with actual product name and save to output file
sed "s/\${PRODUCT_NAME}/$PRODUCT_NAME/g" "$INPUT_FILE" > "$OUTPUT_FILE"

echo "template processed successfully: $OUTPUT_FILE"