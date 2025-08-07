#!/bin/bash

# Đường dẫn thư mục gốc repo
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/code_summary.txt"

# Xóa file cũ nếu tồn tại
rm -f "$OUTPUT_FILE"

echo "Generating code summary at $OUTPUT_FILE..."
echo "==== CODE SUMMARY: $(date) ====" >> "$OUTPUT_FILE"

# Tìm tất cả file .py, .sh (loại trừ các thư mục __pycache__ và *.pyc)
find "$ROOT_DIR" -type f \( -name "*.py" -o -name "*.sh" \) ! -path "*/__pycache__/*" ! -name "*.pyc" | sort | while read filepath; do
    echo -e "\n\n### FILE: ${filepath#$ROOT_DIR/}" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"
    cat "$filepath" >> "$OUTPUT_FILE"
done

echo "Done."
