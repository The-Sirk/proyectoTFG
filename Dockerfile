# Etapa 1: Construcción de la aplicación Flutter
FROM ghcr.io/cirruslabs/flutter:3.35.6 AS build

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY frontFlixScore/front_flixscore/pubspec.* ./

# Descargar dependencias
RUN flutter pub get

# Copiar el resto del proyecto
COPY frontFlixScore/front_flixscore/ ./

# Construir la aplicación para web en modo release
RUN flutter build web --release

# Etapa 2: Servidor de producción
FROM nginx:alpine

# Me aseguro de que gettext se descarga
RUN apk add --no-cache gettext

# Copiar los archivos construidos desde la etapa anterior
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar los archivos HTML de términos y privacidad
COPY --from=build /app/web/politica-privacidad.html /usr/share/nginx/html/
COPY --from=build /app/web/terminos-servicio.html /usr/share/nginx/html/

# Crear configuración de nginx para Cloud Run
RUN echo 'server { \
    listen ${PORT}; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
    try_files $uri $uri/ /index.html; \
    } \
    \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
    expires 1y; \
    add_header Cache-Control "public, immutable"; \
    try_files $uri =404; \
    } \
    \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript; \
    }' > /etc/nginx/conf.d/default.conf.template

EXPOSE 8080

CMD ["/bin/sh", "-c", "envsubst '$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
