FROM maven:3.6.3-openjdk-11 as Build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=Build /app/target/tpAchatProject-*.jar app.jar
EXPOSE 8089
CMD [ "java", "-jar", "app.jar" ]