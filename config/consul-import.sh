#!/bin/bash

# 매개변수로 profile 이 지징되어 전달될 경우 해당 profile yaml 파일만 조회하여 consul 에 import 한다.
if [ ! -z $1 ]; then
  profileSuffix="-$1.yaml"
else
  profileSuffix="-default.yaml"
fi

# consul url 설정 확인
if [ ! -z $CONSUL_URL ]; then
  consulUrl=$CONSUL_URL
elif [ ! -z $2 ]; then
  consulUrl=$2
else
  consulUrl="http://127.0.0.1:8500"
fi

importCount=0 # import 수 조회 변수 선언

for file in **/*${profileSuffix}; do # 파일 목록 조회 Loop
    if [ -s $file ]; then # 내용이 존재하는 파일이라면
        filename="$(basename "$file")" # config file 명 조회
        profileName=${filename%$profileSuffix} # profile file 파일명 뒤에 삭제 처리

        if [ ! -z $CONSUL_AUTH ]; then
          curl \
            -u $CONSUL_AUTH:$CONSUL_PASS \
            -X DELETE \
            "$consulUrl/v1/kv/config/${profileName}\?recurse"
          # 기존의 profile data 삭제

          curl \
            -u $CONSUL_AUTH:$CONSUL_PASS \
            -X PUT \
            --data-binary @$file \
            "$consulUrl/v1/kv/config/${profileName}/data"
          # 갱신된 profile data import
        else
          curl \
            -X DELETE \
            "$consulUrl/v1/kv/config/${profileName}\?recurse"
          # 기존의 profile data 삭제

          curl \
            -X PUT \
            --data-binary @$file \
            "$consulUrl/v1/kv/config/${profileName}/data"
          # 갱신된 profile data import
        fi

        importCount=$((${importCount}+1)) # consul import 수 증가
    fi
done

if [ $importCount == 0 ]; then
  echo "Import profile not exist. Rquest profile is \"${profile:1}\""
fi
# curl -X DELETE http://127.0.0.1:8500/v1/kv/config/post-service\?recurse