#!/bin/bash

# Save Directory (C:\savedurl)
SAVE_DIR="/mnt/c/savedurl"
mkdir -p "$SAVE_DIR"

# URL decode function (Robust UTF-8)
urldecode() {
    local url_encoded="${1}"
    echo -e "$(sed 's/+/ /g; s/%/\\x/g' <<< "${url_encoded}")"
}

# 1. Get URL Input
read -p "URL Input: " url

# PDF Path (file:///) Processing

if [[ "$url" == file://* ]] then
    echo "PDF : $url"

     # Remove file:/// part
    encoded_path="${url#file:///}"

    # UTF-8 URL Decode
    decoded_path=$(urldecode "$encoded_path")

    # Windows Path -> WSL Path (/mnt/c/...)
    local_path=$(wslpath "$decoded_path")
    echo "WSL PDF Path: $local_path"

    # Check file existence
    if test ! -f "$local_path" 
    then
        echo "로컬 파일을 찾을 수 없습니다: $local_path"
        exit 1
    fi

    # Extract filename (remove extension)
    base=$(basename "$local_path")
    filename="${base%.*}.txt"

    # Check for duplicates
    if [[ -f "$SAVE_DIR/$filename" ]]; then
        echo "파일이 이미 존재합니다: $SAVE_DIR/$filename"
        exit 0
    fi

    # PDF -> TXT Conversion (requires poppler-utils)
    pdftotext "$local_path" "$SAVE_DIR/$filename"
    echo "PDF → 텍스트 변환 완료: $SAVE_DIR/$filename"

    # Convert to Windows Path (C:\...)
    win_saved_path=$(wslpath -w "$SAVE_DIR/$filename")
    echo "저장된 텍스트 파일 경로 (Windows): $win_saved_path"

    # Open with Windows Notepad
    notepad.exe "$win_saved_path"
    exit 0
fi

# General URL (http, https) Processing

# Check URL accessibility
curl -Is "$url" > /dev/null || { echo "URL 접근 불가: $url"; exit 1; }

# URL -> Filename conversion
filename=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g').txt

# Check for duplicates
if [ -f "$SAVE_DIR/$filename" ]; then
    echo "파일이 이미 존재합니다: $SAVE_DIR/$filename"
    exit 0
fi

# URL -> Text Save
lynx -dump "$url" > "$SAVE_DIR/$filename"
echo "저장 완료: $SAVE_DIR/$filename"

# Open Saved File

if grep -qi "microsoft" /proc/version 2>/dev/null; then
    # WSL 
    /mnt/c/Windows/System32/notepad.exe "$(wslpath -w "$SAVE_DIR/$filename")"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Git Bash or Cygwin
    notepad.exe "$SAVE_DIR/$filename"
else
    # linux
    xdg-open "$SAVE_DIR/$filename"
fi

