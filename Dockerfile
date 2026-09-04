# ---- 1단계: 컴파일 ----
# 이 프로젝트는 Maven/Gradle 없이 순수 소스라서, javac로 직접 컴파일합니다.
FROM eclipse-temurin:21-jdk AS build
WORKDIR /build

COPY src/main/java ./src
COPY src/main/webapp/WEB-INF/lib ./lib

RUN mkdir -p /build/classes && \
    find ./src -name "*.java" > sources.txt && \
    javac -encoding UTF-8 -d /build/classes \
        -cp "$(find ./lib -name '*.jar' | tr '\n' ':')" \
        @sources.txt

# ---- 2단계: Tomcat에 배포 ----
FROM tomcat:10.1-jdk21-temurin

# 기본 예제 웹앱 제거하고, 우리 앱을 ROOT 컨텍스트(/)로 배포
RUN rm -rf /usr/local/tomcat/webapps/*
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT
COPY --from=build /build/classes /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Render는 컨테이너가 $PORT로 리스닝하기를 기대합니다.
# 컨테이너 시작 시 Tomcat 설정의 포트를 $PORT 값으로 바꿔줍니다.
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
