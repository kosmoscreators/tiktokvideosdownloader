#!/usr/bin/env powershell

Write-Host "Cat Education Video Downloader" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Create directory for videos
$videoDir = "cat-education-videos"
if (!(Test-Path $videoDir)) {
    New-Item -ItemType Directory -Path $videoDir
    Write-Host "Created directory: $videoDir" -ForegroundColor Yellow
}

# Array of cat-related hashtags to try
$hashtags = @("catcare", "cats", "kitten", "cattips", "cattraining", "petcare", "catbehavior", "catlovers", "cateducation", "cathelp")

# Function to try downloading with different approaches
function Try-Download {
    param(
        [string]$hashtag,
        [int]$count = 2
    )
    
    Write-Host "Trying hashtag: #$hashtag" -ForegroundColor Cyan
    
    # Try 1: Basic download
    Write-Host "  Attempt 1: Basic download" -ForegroundColor Gray
    & tiktok-scraper hashtag $hashtag -n $count -d -w -t json --filepath "./$videoDir" --filename $hashtag 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Success with basic download" -ForegroundColor Green
        return $true
    }
    
    # Try 2: With test endpoints
    Write-Host "  Attempt 2: Using test endpoints" -ForegroundColor Gray
    & tiktok-scraper hashtag $hashtag -n $count -d -w -t json --useTestEndpoints --filepath "./$videoDir" --filename $hashtag 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Success with test endpoints" -ForegroundColor Green
        return $true
    }
    
    # Try 3: With timeout
    Write-Host "  Attempt 3: With timeout delay" -ForegroundColor Gray
    & tiktok-scraper hashtag $hashtag -n $count -d -w -t json --timeout 5000 --filepath "./$videoDir" --filename $hashtag 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Success with timeout" -ForegroundColor Green
        return $true
    }
    
    Write-Host "  ❌ Failed for hashtag: $hashtag" -ForegroundColor Red
    return $false
}

# Main download process
$successCount = 0
$targetVideos = 10

Write-Host ""
Write-Host "Starting download process..." -ForegroundColor Blue
Write-Host "Target: $targetVideos videos for cat education" -ForegroundColor Blue
Write-Host ""

foreach ($hashtag in $hashtags) {
    if ($successCount -ge $targetVideos) {
        break
    }
    
    $remaining = $targetVideos - $successCount
    $toDownload = [Math]::Min(3, $remaining)
    
    $success = Try-Download -hashtag $hashtag -count $toDownload
    if ($success) {
        $successCount += $toDownload
        Write-Host "Total downloaded so far: $successCount" -ForegroundColor Green
    }
    
    # Small delay between different hashtags
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Download Summary:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

# Check what was actually downloaded
$downloadedFiles = Get-ChildItem -Path $videoDir -Recurse -Include "*.mp4" -ErrorAction SilentlyContinue
$jsonFiles = Get-ChildItem -Path $videoDir -Recurse -Include "*.json" -ErrorAction SilentlyContinue

if ($downloadedFiles.Count -gt 0) {
    Write-Host "✅ Successfully downloaded $($downloadedFiles.Count) video files" -ForegroundColor Green
    Write-Host "✅ Generated $($jsonFiles.Count) metadata files" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files location: $videoDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Downloaded files:" -ForegroundColor White
    $downloadedFiles | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
} else {
    Write-Host "❌ No videos were downloaded" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might be due to:" -ForegroundColor Yellow
    Write-Host "- TikTok blocking requests (403 Forbidden)" -ForegroundColor Gray
    Write-Host "- Network connectivity issues" -ForegroundColor Gray
    Write-Host "- Rate limiting" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Solutions to try:" -ForegroundColor Cyan
    Write-Host "1. Get a session cookie (see GET_SESSION_GUIDE.md)" -ForegroundColor Gray
    Write-Host "2. Use a VPN or proxy" -ForegroundColor Gray
    Write-Host "3. Try downloading individual video URLs" -ForegroundColor Gray
    Write-Host "4. Try again later (different time of day)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "For better success rates, read: GET_SESSION_GUIDE.md" -ForegroundColor Cyan