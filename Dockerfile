# 멀티 스테이지 빌드를 사용
# 1. 최종 이미지를 작게 유지
# 2. 프로젝트 하위 jar file 의존성 제거

# 첫 번째 단계: 애플리케이션 빌드
FROM bellsoft/liberica-openjdk-alpine:17 AS build

# 작업 디렉토리를 설정합니다.
WORKDIR /app

# Gradle 래퍼 및 필요한 파일들을 복사합니다.
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle build.gradle
COPY settings.gradle settings.gradle

# 소스 코드를 복사합니다.
COPY src src

# Gradle 래퍼에 실행 권한을 부여합니다.
RUN chmod +x gradlew

# 애플리케이션을 빌드합니다.
RUN ./gradlew clean build

# 두 번째 단계: 최종 이미지 생성
FROM bellsoft/liberica-openjdk-alpine:17

# 작업 디렉토리를 설정합니다.
WORKDIR /app

# 빌드 단계에서 생성된 JAR 파일을 복사합니다.
COPY --from=build /app/build/libs/*.jar /app/app.jar

# 애플리케이션 포트를 엽니다.
EXPOSE 8080

# 컨테이너가 시작될 때 애플리케이션을 실행하도록 엔트리 포인트를 설정합니다.
ENTRYPOINT ["java","-jar","/app/app.jar"]