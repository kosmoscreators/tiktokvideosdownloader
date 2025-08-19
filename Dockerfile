# Use official Node.js runtime as base image
FROM node:18-slim

# Set working directory
WORKDIR /usr/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy source code
COPY ./src ./src
COPY ./bin ./bin

# Build the project
RUN npm run build

# Remove source files and dev dependencies
RUN rm -rf src && npm prune --production

# Set environment variable
ENV SCRAPING_FROM_DOCKER=1

# Create files directory
RUN mkdir -p files

# Set the entrypoint
ENTRYPOINT [ "node", "bin/cli.js" ]
