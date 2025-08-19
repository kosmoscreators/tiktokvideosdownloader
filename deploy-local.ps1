#!/usr/bin/env powershell

Write-Host "TikTok Scraper Local Deployment Script" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "Node.js version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Create necessary directories
if (!(Test-Path "downloads")) {
    New-Item -ItemType Directory -Path "downloads"
    Write-Host "Created downloads directory" -ForegroundColor Yellow
}

if (!(Test-Path "history")) {
    New-Item -ItemType Directory -Path "history"  
    Write-Host "Created history directory" -ForegroundColor Yellow
}

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Blue
npm install --legacy-peer-deps

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

# Build the project
Write-Host "Building the project..." -ForegroundColor Blue
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Link globally (optional)
Write-Host "Linking package globally..." -ForegroundColor Blue
npm link

Write-Host ""
Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage examples:" -ForegroundColor Cyan
Write-Host "1. Show help:" -ForegroundColor White
Write-Host "   tiktok-scraper --help" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Scrape user feed:" -ForegroundColor White
Write-Host "   tiktok-scraper user USERNAME -n 10 -d -t json" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Scrape hashtag feed:" -ForegroundColor White  
Write-Host "   tiktok-scraper hashtag HASHTAG -n 5 -d -t json" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Download single video:" -ForegroundColor White
Write-Host "   tiktok-scraper video `"https://www.tiktok.com/@user/video/123456`" -d" -ForegroundColor Gray
Write-Host ""
Write-Host "Files will be saved to the current directory or specify with --filepath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test the installation:" -ForegroundColor Cyan
tiktok-scraper --help