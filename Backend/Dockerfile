FROM maven:3.6.3-openjdk-11 AS maven_build
COPY pom.xml /tmp/
COPY src /tmp/src/
WORKDIR /tmp/
RUN mvn package

FROM openjdk
MAINTAINER mariol_gjerazi@hotmail.com
EXPOSE 8080
CMD java -jar /data/quiz-0.0.1-SNAPSHOT.jar
COPY --from=maven_build /tmp/target/quiz-0.0.1-SNAPSHOT.jar /data/quiz-0.0.1-SNAPSHOT.jar


#BEST PRACTICE

#from openjdk:11-slim-buster as builder
#add . /opt/app/
#workdir /opt/app
#run ./mvnw package
#from openjdk:11-slim-buster
#copy --from=builder /opt/app/target/quiz-0.0.1-SNAPSHOT.jar /opt/app/quiz-backend.jar
#entrypoint ["java", "-jar", "/opt/app/quiz-backend.jar"]





