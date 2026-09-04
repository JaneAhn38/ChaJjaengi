#!/bin/sh
set -e

# Render가 넘겨주는 PORT 환경변수로 Tomcat의 리스닝 포트를 맞춥니다.
PORT="${PORT:-8080}"
sed -i "s/port=\"8080\"/port=\"$PORT\"/" /usr/local/tomcat/conf/server.xml

# 컨테이너 환경에서는 원격 종료 포트(8005)가 필요 없고, 외부에서 계속 그
# 포트로 들어오는 트래픽 때문에 "Invalid shutdown command" 경고 로그만
# 쌓이므로 아예 비활성화합니다. (컨테이너 종료는 SIGTERM으로 처리됨)
sed -i 's/port="8005" shutdown="SHUTDOWN"/port="-1" shutdown="SHUTDOWN"/' /usr/local/tomcat/conf/server.xml

exec catalina.sh run
