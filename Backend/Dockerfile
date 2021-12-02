from openjdk:11-slim-buster as builder
add . /opt/app/
workdir /opt/app
run ./mvnw package
from openjdk:11-slim-buster
copy --from=builder /opt/app/target/quiz-0.0.1-SNAPSHOT.jar /opt/app/quiz-backend.jar
entrypoint ["java", "-jar", "/opt/app/quiz-backend.jar"]