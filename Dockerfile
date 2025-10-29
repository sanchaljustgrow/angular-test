# ===============================
# Stage 1 — Build Angular app
# ===============================
FROM node:20-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install -g @angular/cli && npm install

# Copy project files
COPY . .

# Replace apiUrl dynamically if passed as build arg
ARG API_URL=http://localhost:8081/v1
RUN sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/environments/environment.ts

# ✅ Build Angular app for production
RUN npx ng build --configuration production

# ===============================
# Stage 2 — Serve via NGINX
# ===============================
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
