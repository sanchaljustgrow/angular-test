# ===============================
# Stage 1 — Build Angular app
# ===============================
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install -g @angular/cli && npm install

# Copy the entire project
COPY . .

# Accept API_URL as build argument
ARG API_URL=http://localhost:8081/v1

# 🔧 Replace apiUrl dynamically in your environment file
RUN sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/app/environments/environment.ts

# ✅ Build Angular app for production
RUN npx ng build --configuration production

# ===============================
# Stage 2 — Serve via NGINX
# ===============================
FROM nginx:alpine

# Copy built Angular app from previous stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
