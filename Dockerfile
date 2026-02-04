# Build stage
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package files
COPY package.json bun.lock* ./

# Install dependencies
RUN bun install --no-save

# Copy source code
COPY . .

# Build the application
RUN bun run build

# Production stage
FROM nginx:alpine

# Cache bust argument - change this value to force rebuild
ARG CACHEBUST=4

# Replace the MAIN nginx.conf with our custom one
COPY nginx.conf /etc/nginx/nginx.conf

# Verify the config
RUN echo "=== NGINX CONFIG ===" && cat /etc/nginx/nginx.conf

# Copy built application from builder stage
WORKDIR /usr/share/nginx/html/
RUN rm -rf ./*
COPY --from=builder /app/dist .

# List files and test nginx config
RUN ls -la /usr/share/nginx/html/ && \
    echo "=== TESTING NGINX CONFIG ===" && \
    nginx -t

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
