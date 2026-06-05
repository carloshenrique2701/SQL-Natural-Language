# Estágio de Compilação
FROM maven:3.9-amazoncorretto-25-al2023 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Estágio de Execução
FROM amazoncorretto:25
WORKDIR /app
COPY --from=build /app/target/*-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080

# Comando limpo e direto
CMD ["java", "-jar", "app.jar"]
