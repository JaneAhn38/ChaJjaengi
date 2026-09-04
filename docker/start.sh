#!/bin/sh
set -e

# Render가 넘겨주는 PORT 환경변수로 Tomcat의 리스닝 포트를 맞춥니다.
PORT="${PORT:-8080}"
sed -i "s/port=\"8080\"/port=\"$PORT\"/" /usr/local/tomcat/conf/server.xml

exec catalina.sh run
