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