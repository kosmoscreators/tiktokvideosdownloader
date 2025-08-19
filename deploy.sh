#!/bin/bash

echo "TikTok Scraper Deployment Script"
echo "================================"

# Create necessary directories
mkdir -p downloads
mkdir -p history

# Build Docker image
echo "Building Docker image..."
docker build -t tiktok-scraper .

if [ $? -eq 0 ]; then
    echo "Docker image built successfully!"
    echo ""
    echo "Usage examples:"
    echo "1. Show help:"
    echo "   docker run -v \$(pwd)/downloads:/usr/app/files tiktok-scraper --help"
    echo ""
    echo "2. Scrape user feed:"
    echo "   docker run -v \$(pwd)/downloads:/usr/app/files tiktok-scraper user USERNAME -n 10 -d -t json"
    echo ""
    echo "3. Scrape hashtag feed:"
    echo "   docker run -v \$(pwd)/downloads:/usr/app/files tiktok-scraper hashtag HASHTAG -n 5 -d -t json"
    echo ""
    echo "4. Using docker-compose:"
    echo "   docker-compose up tiktok-scraper"
    echo ""
    echo "Files will be saved to the 'downloads' directory."
else
    echo "Docker build failed!"
    exit 1
fi