# ===============================
# Stage 1 — Build Angular app
# ===============================
FROM node:20-alpine AS build

WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install -g @angular/cli && npm install

# Copy source code
COPY . .

# Inject API URL dynamically
ARG API_URL=http://localhost:8081/v1
ENV API_URL=${API_URL}

# ✅ Update correct path (src/app/environments)
RUN if [ -f src/app/environments/environment.ts ]; then \
      sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/app/environments/environment.ts; \
    else \
      echo "⚠️ environment.ts not found in src/app/environments"; \
    fi

# Build Angular app for production
RUN ng build --configuration production

# ===============================
# Stage 2 — Serve using NGINX
# ===============================
FROM nginx:alpine

# Copy compiled app from builder
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
