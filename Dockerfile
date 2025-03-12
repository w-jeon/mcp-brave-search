# First Stage: Build
FROM node:22.12-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first (Docker caching optimization)
COPY package.json ./

# Install dependencies (this is required for build)
RUN --mount=type=cache,target=/root/.npm npm install

# Copy the rest of the project files AFTER installing dependencies
COPY . .

# Compile TypeScript
RUN npm run build

# Second Stage: Production
FROM node:22-alpine AS release

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package-lock.json ./

# Set environment
ENV NODE_ENV=production

# Install only production dependencies
RUN npm ci --ignore-scripts --omit=dev

# Expose the application's port (adjust if necessary)
EXPOSE 8080

# Start the application
ENTRYPOINT ["node", "dist/index.js"]
