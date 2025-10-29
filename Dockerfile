# Stage 1: Build
FROM node:18 AS build
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Optional quick fix for broken CSS
RUN sed -i 's|url(|/*url(|g' src/app/login/login.component.css

# Build Angular without CSS optimization
RUN npm run build -- --configuration production --optimization=false

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/dist/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
