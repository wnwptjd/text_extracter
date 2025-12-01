#!/bin/bash

SAVE_DIR="/mnt/c/savedurl"
mkdir -p "$SAVE_DIR"

#1 url 입력받기
read -p "URL 입력: " url

#2 접속 가능여부 확인
curl -Is "$url" > /dev/null || { echo "URL 접근 불가: $url"; exit 1; }

#3 url > .txt
filename=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g').txt

#4 겹치는 파일 확인
if [ -f "$SAVE_DIR/$filename" ]; then
    echo "파일이 이미 존재합니다: $SAVE_DIR/$filename"
    exit 0
fi

#5 텍스트 추출
lynx -dump "$url" > "$SAVE_DIR/$filename"

#6 저장 완료 시 메시지 출력
echo "저장 완료: $SAVE_DIR/$filename"

#7 저장 완료 txt 열기
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    # WSL 환경
    /mnt/c/Windows/System32/notepad.exe "$(wslpath -w "$SAVE_DIR/$filename")"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Git Bash 또는 Cygwin
    notepad.exe "$SAVE_DIR/$filename"
else
    # 리눅스는 기본 뷰어로
    xdg-open "$SAVE_DIR/$filename"
fi

# PDF > TXT
# 주소가 file:///c:/... 형태일 때

if [[ "$url" == file://* ]]; then
    echo "PDF : $url"

    # file:///C:/~~ 를 떼고 디코딩
    encoded_path="${url#file:///}"
    decoded_path=$(urldecode "$encoded_path")

    # Windows 경로 → WSL 경로(/mnt/c/~~)
    # 예: C:/Users/... → /mnt/c/Users/...
    local_path="/mnt/c/${decoded_path#C:/}"

    # 파일 존재 확인
    if [[ ! -f "$local_path" ]]; then
        echo "로컬 파일을 찾을 수 없습니다: $local_path"
        exit 1
    fi

    # pdf 파일명 추출
    base=$(basename "$local_path")
    filename="${base}.txt"

    # 중복 체크
    if [[ -f "$SAVE_DIR/$filename" ]]; then
        echo "파일이 이미 존재합니다: $SAVE_DIR/$filename"
        exit 0
    fi

    # PDF → TXT 변환 (poppler-utils 필요)
    pdftotext "$local_path" "$SAVE_DIR/$filename"
    echo "PDF → 텍스트 변환 완료: $SAVE_DIR/$filename"

    # Windows에서 메모장으로 열기
    /mnt/c/Windows/System32/notepad.exe "$(wslpath -w "$SAVE_DIR/$filename")"

    exit 0
fi