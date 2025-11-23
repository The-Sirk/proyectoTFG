# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

WORKDIR /app

# Copiar archivos de dependencias
COPY frontFlixScore/front_flixscore/pubspec.* ./
RUN flutter pub get

# Copiar el resto del proyecto
COPY frontFlixScore/front_flixscore/ ./

# Build para producción
RUN flutter build web --release
