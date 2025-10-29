# ============================
# Stage 1: Build Angular App
# ============================
FROM node:20 AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install -g @angular/cli@latest && npm install

# Copy the entire project
COPY . .

# Optionally override API URL at build time (can be passed via --build-arg)
ARG API_URL=http://localhost:8081/v1

# Replace apiUrl in environment.ts dynamically
RUN sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/app/environments/environment.ts

# Build Angular app for production
RUN npm run build -- --configuration production

# ============================
# Stage 2: Serve with Nginx
# ============================
FROM nginx:alpine

# Copy the Angular build output to Nginx's HTML folder
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom Nginx config (optional)
# Uncomment this if you have an nginx.conf file in your repo
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
