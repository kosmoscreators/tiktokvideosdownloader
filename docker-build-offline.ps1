#!/usr/bin/env powershell

Write-Host "TikTok Scraper Offline Docker Build" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Try using a cached base image first
Write-Host "Attempting to use cached Node.js image..." -ForegroundColor Blue

# Check if we have any Node.js images locally
$nodeImages = docker images node --format "table {{.Repository}}:{{.Tag}}" | Select-String "node:"
if ($nodeImages.Count -gt 0) {
    Write-Host "Found local Node.js images:" -ForegroundColor Green
    $nodeImages | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    # Use the first available node image
    $firstImage = ($nodeImages[0] -split "\s+")[0]
    Write-Host "Using: $firstImage" -ForegroundColor Yellow
    
    # Create a temporary Dockerfile using the cached image
    $dockerfileContent = @"
# Use locally cached Node.js image
FROM $firstImage

# Set working directory  
WORKDIR /usr/app

# Install system dependencies if needed
RUN apt-get update && apt-get install -y python3 build-essential || apk add --no-cache python3 make g++

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
"@

    $dockerfileContent | Out-File -FilePath "Dockerfile.offline" -Encoding UTF8
    
    Write-Host "Building with cached image..." -ForegroundColor Blue
    docker build -f Dockerfile.offline -t tiktok-scraper .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Offline Docker build successful!" -ForegroundColor Green
        # Clean up temporary Dockerfile
        Remove-Item "Dockerfile.offline" -Force
        
        # Test the image
        Write-Host "Testing the Docker image..." -ForegroundColor Blue
        docker run --rm tiktok-scraper --help
        
        Write-Host ""
        Write-Host "Usage examples:" -ForegroundColor Cyan
        Write-Host "docker run --rm -v `"$(Get-Location)\downloads:/usr/app/files`" tiktok-scraper user USERNAME -n 5 -d -t json" -ForegroundColor Gray
    } else {
        Write-Host "Offline build failed!" -ForegroundColor Red
        Remove-Item "Dockerfile.offline" -Force -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "No cached Node.js images found." -ForegroundColor Yellow
    Write-Host "Please try one of these options:" -ForegroundColor Cyan
    Write-Host "1. Use local deployment: .\deploy-local.ps1" -ForegroundColor Gray
    Write-Host "2. Fix network connectivity and run: .\deploy.ps1" -ForegroundColor Gray
    Write-Host "3. Manually pull a Node.js image when network is available:" -ForegroundColor Gray
    Write-Host "   docker pull node:18-slim" -ForegroundColor Gray
}