# ===============================
# Stage 1 — Build Angular app
# ===============================
FROM node:20-alpine AS build

# Install required tools
RUN apk add --no-cache bash

# Set working directory
WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install dependencies and Angular CLI
RUN npm install -g @angular/cli && npm install

# Copy the rest of the app
COPY . .

# Build argument for API
ARG API_URL=http://localhost:8081/v1
ENV API_URL=${API_URL}

# Update apiUrl dynamically (if exists)
RUN if [ -f src/app/environments/environment.ts ]; then \
      sed -i "s|apiUrl: '.*'|apiUrl: '${API_URL}'|g" src/app/environments/environment.ts; \
    else \
      echo "⚠️ environment.ts not found — skipping replacement"; \
    fi

# ✅ Use safer build (detects config automatically)
RUN npx ng build --configuration production || npx ng build --prod

# ===============================
# Stage 2 — Serve via NGINX
# ===============================
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
