
# Stage 1 — Build Angular app

FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies and Angular CLI
RUN npm install -g @angular/cli && npm install

# Copy source code
COPY . .

# Set environment variable (available during build)
ARG API_URL=http://localhost:8081/v1
ENV API_URL=${API_URL}

# Replace apiUrl in environment.ts dynamically before building
RUN sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/environments/environment.ts

# Build Angular for production
RUN ng build --configuration production


# Stage 2 — Serve using NGINX

FROM nginx:alpine

# Copy build output to nginx folder
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
