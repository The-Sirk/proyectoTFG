# ----------------------------------------------------------------------
# Etapa 1: BUILDER - Compila la aplicación y crea el JAR
# ----------------------------------------------------------------------
FROM maven:3.9.5-eclipse-temurin-17-alpine AS builder

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia solo el archivo pom.xml que está dentro de la carpeta FlixScore
COPY FlixScore/pom.xml .

# Descarga las dependencias
RUN mvn dependency:go-offline

# Copia el código fuente
COPY FlixScore/src ./src

# Empaqueta la aplicación en un JAR
RUN mvn clean package -DskipTests

# ----------------------------------------------------------------------
# Etapa 2: RUNNER - Crea la imagen final de ejecución
# ----------------------------------------------------------------------
FROM eclipse-temurin:17-jre-alpine

# Define un argumento para el nombre del archivo JAR compilado
ARG JAR_FILE=target/ira-0.0.1-SNAPSHOT.jar 

# Define el puerto que escuchará la aplicación
EXPOSE 8080

# Copia el JAR compilado de la etapa 'builder'
COPY --from=builder /app/${JAR_FILE} /app.jar

# Define la entrada (entrypoint) para ejecutar el JAR
ENTRYPOINT ["java", "-jar", "/app.jar"]