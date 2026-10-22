
# Stage 1: Build React frontend
FROM node:20-alpine AS frontend-builder

WORKDIR /app

COPY frontend/package*.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build


# Stage 2: Run Node.js backend
FROM node:20-alpine AS production

WORKDIR /app

COPY backend/package*.json ./
RUN npm install --omit=dev

COPY backend/ ./

# Copy React production build into backend's public directory
COPY --from=frontend-builder /app/dist /app/public

EXPOSE 5000

CMD ["node", "server.js"]

