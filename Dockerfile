# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Enable web support (required in some Docker environments)
RUN flutter config --enable-web

# Copy pubspec files first for better layer caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Clean and build (--no-source-maps reduces memory usage during compilation)
RUN flutter clean && flutter pub get && flutter build web --release --no-source-maps

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
