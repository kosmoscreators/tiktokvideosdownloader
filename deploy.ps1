#!/usr/bin/env powershell

Write-Host "TikTok Scraper Deployment Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Check if Docker is running
try {
    $dockerVersion = docker version --format "{{.Client.Version}}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not responding"
    }
    Write-Host "Docker version: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker is not running or not installed!" -ForegroundColor Red
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    Write-Host "2. Start Docker Desktop" -ForegroundColor Yellow
    Write-Host "3. Wait for Docker to fully start" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Use local deployment instead:" -ForegroundColor Cyan
    Write-Host ".\deploy-local.ps1" -ForegroundColor Gray
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

# Test Docker Hub connectivity
Write-Host "Testing Docker Hub connectivity..." -ForegroundColor Blue
try {
    $testPull = docker pull hello-world 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Warning: Docker Hub connectivity issues detected" -ForegroundColor Yellow
        Write-Host "This might be due to network restrictions or proxy settings" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Alternative solutions:" -ForegroundColor Cyan
        Write-Host "1. Use local deployment: .\deploy-local.ps1" -ForegroundColor Gray
        Write-Host "2. Configure Docker to use a proxy if needed" -ForegroundColor Gray
        Write-Host "3. Try again later when network is stable" -ForegroundColor Gray
        
        $response = Read-Host "Continue with Docker build anyway? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Cancelled. Use .\deploy-local.ps1 for local deployment." -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host "Docker Hub connectivity OK" -ForegroundColor Green
        docker rmi hello-world 2>$null
    }
} catch {
    Write-Host "Docker connectivity test failed" -ForegroundColor Yellow
}

# Build Docker image
Write-Host "Building Docker image..." -ForegroundColor Blue
docker build -t tiktok-scraper .

if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker image built successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Test the built image
    Write-Host "Testing the Docker image..." -ForegroundColor Blue
    $testResult = docker run --rm tiktok-scraper --help 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker image test successful!" -ForegroundColor Green
    } else {
        Write-Host "Warning: Docker image test failed" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Usage examples:" -ForegroundColor Cyan
    Write-Host "1. Show help:" -ForegroundColor White
    Write-Host "   docker run --rm -v `"$(Get-Location)\downloads:/usr/app/files`" tiktok-scraper --help" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Scrape user feed:" -ForegroundColor White
    Write-Host "   docker run --rm -v `"$(Get-Location)\downloads:/usr/app/files`" tiktok-scraper user USERNAME -n 10 -d -t json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Scrape hashtag feed:" -ForegroundColor White
    Write-Host "   docker run --rm -v `"$(Get-Location)\downloads:/usr/app/files`" tiktok-scraper hashtag HASHTAG -n 5 -d -t json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Using docker-compose:" -ForegroundColor White
    Write-Host "   docker-compose up tiktok-scraper" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Files will be saved to the 'downloads' directory." -ForegroundColor Yellow
} else {
    Write-Host "Docker build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "1. Check internet connection" -ForegroundColor Gray
    Write-Host "2. Restart Docker Desktop" -ForegroundColor Gray
    Write-Host "3. Use local deployment: .\deploy-local.ps1" -ForegroundColor Gray
    Write-Host "4. Configure proxy if behind corporate firewall" -ForegroundColor Gray
    exit 1
}