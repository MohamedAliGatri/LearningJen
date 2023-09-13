FROM openjdk:21-jdk-slim
WORKDIR /app
COPY /target/tpAchatProject-*.jar app.jar
EXPOSE 8089
CMD [ "java", "-jar", "app.jar" ]