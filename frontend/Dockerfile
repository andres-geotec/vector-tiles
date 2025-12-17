# --- build stage ---
FROM node:20-alpine AS build
RUN apk add --no-cache git

ARG REPO_URL
ARG REPO_REF=main
ARG BUILD_DIR=dist

WORKDIR /app
RUN test -n "$REPO_URL" || (echo "Falta REPO_URL" && exit 1)

# Clona el repo
RUN git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" .

# Instala y construye (ajusta si usas pnpm/yarn)
RUN npm i
RUN npm run build

# --- serve stage ---
FROM nginx:alpine
ARG BUILD_DIR=dist

# Nginx config con proxy a Martin
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia build
COPY --from=build /app/${BUILD_DIR} /usr/share/nginx/html
