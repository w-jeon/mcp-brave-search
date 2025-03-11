FROM node:22.12-alpine AS builder

# Set working directory
WORKDIR /app

# Copy only package.json first for efficient caching
COPY package.json ./

# Install dependencies
RUN --mount=type=cache,target=/root/.npm npm install

# Copy the remaining project files (including tsconfig.json and index.ts)
COPY . .

# Compile TypeScript code
RUN npm run build

FROM node:22-alpine AS release

# Set working directory
WORKDIR /app

# Copy built files from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/package.json /app/package.json

# Set production environment
ENV NODE_ENV=production

# Install only production dependencies
RUN npm install --omit=dev

# Start the application
ENTRYPOINT ["node", "dist/index.js"]
