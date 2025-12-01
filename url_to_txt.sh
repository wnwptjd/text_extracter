#!/bin/bash

#1 url 입력받기
read -p "URL 입력: " url

#2 접속 가능여부 확인
curl -Is "$url" > /dev/null || { echo "URL 접근 불가: $url"; exit 1; }

#3 url > .txt
filename=$(echo "$url" | sed 's/[^a-zA-Z0-9]/_/g').txt

#4 파일 저장 폴더 생성
mkdir -p savedurl

#5 겹치는 파일 확인
if [ -f "savedurl/$filename" ]; then
    echo "파일이 이미 존재합니다: savedurl/$filename"
    exit 0
fi

#6 텍스트 추출
lynx -dump "$url" > "savedurl/$filename"

#7 저장 완료 시 메시지 출력
echo "저장 완료: savedurl/$filename"

#8 저장 완료 txt 열기
xdg-open "savedurl/$filename"

if grep -qi "microsoft" /proc/version 2>/dev/null; then
    # WSL 환경
    /mnt/c/Windows/System32/notepad.exe "savedurl/$filename"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Git Bash 또는 Cygwin
    notepad.exe "savedurl/$filename"
else
    # 리눅스는 기본 뷰어로
    xdg-open "savedurl/$filename"
fi