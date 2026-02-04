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
ARG CACHEBUST=2

# Remove ALL default nginx configs
RUN rm -rf /etc/nginx/conf.d/*

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Verify the config was copied (for debugging)
RUN cat /etc/nginx/conf.d/default.conf

# Copy built application from builder stage
WORKDIR /usr/share/nginx/html/
RUN rm -rf ./*
COPY --from=builder /app/dist .

# List files to verify (for debugging)
RUN ls -la /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
