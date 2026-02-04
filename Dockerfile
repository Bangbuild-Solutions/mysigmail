FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
WORKDIR /usr/share/nginx/html/
COPY dist .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
