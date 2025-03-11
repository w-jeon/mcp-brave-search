FROM node:22.12-alpine AS builder

# Set working directory
WORKDIR /app

# Copy only package.json and package-lock.json first for better caching
COPY package.json package-lock.json ./

# Install dependencies
RUN --mount=type=cache,target=/root/.npm npm install

# Copy all remaining project files
COPY . .

# Build the TypeScript project
RUN npm run build

FROM node:22-alpine AS release

# Set working directory
WORKDIR /app

# Copy built files from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/package-lock.json /app/package-lock.json

# Set production environment
ENV NODE_ENV=production

# Install only production dependencies
RUN npm ci --ignore-scripts --omit-dev

# Set the entry point for the server
ENTRYPOINT ["node", "dist/index.js"]
