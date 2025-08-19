#!/usr/bin/env powershell

Write-Host "Testing TikTok Access with US IP" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

$testResults = @()

# Test 1: Trending posts
Write-Host "Test 1: Trending posts..." -ForegroundColor Cyan
$result1 = & tiktok-scraper trend -n 1 -t json --timeout 3000 2>&1
$testResults += "Trending: $($result1 -join ' ')"

# Test 2: Popular hashtags
$hashtags = @("cat", "pets", "animal", "cute", "funny")
foreach ($hashtag in $hashtags) {
    Write-Host "Test: Hashtag #$hashtag..." -ForegroundColor Cyan
    $result = & tiktok-scraper hashtag $hashtag -n 1 -t json --timeout 3000 2>&1
    $testResults += "Hashtag $hashtag`: $($result -join ' ')"
    
    if ($result -notlike "*403*" -and $result -notlike "*Can't scrape*") {
        Write-Host "  Potential success with #$hashtag!" -ForegroundColor Green
        # Try to download actual videos
        Write-Host "  Attempting video download..." -ForegroundColor Yellow
        & tiktok-scraper hashtag $hashtag -n 2 -d -w -t json --filepath ./cat-education-videos --filename "success-$hashtag" --timeout 5000
        break
    }
}

# Test 3: Test endpoints
Write-Host "Test 3: Using test endpoints with cats..." -ForegroundColor Cyan
$result3 = & tiktok-scraper hashtag cats -n 1 --useTestEndpoints -t json --timeout 5000 2>&1
$testResults += "Test endpoints: $($result3 -join ' ')"

# Test 4: User profiles
Write-Host "Test 4: User profile access..." -ForegroundColor Cyan
$users = @("tiktok", "nasa", "unicef")
foreach ($user in $users) {
    $result = & tiktok-scraper userprofile $user --timeout 3000 2>&1
    $testResults += "User $user`: $($result -join ' ')"
    if ($result -notlike "*Can't extract*") {
        Write-Host "  User $user works!" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Test Results Summary:" -ForegroundColor Yellow
Write-Host "====================" -ForegroundColor Yellow

foreach ($result in $testResults) {
    if ($result -like "*403*") {
        Write-Host "❌ $result" -ForegroundColor Red
    } elseif ($result -like "*Can't*" -or $result -like "*Error*") {
        Write-Host "⚠️  $result" -ForegroundColor Yellow  
    } else {
        Write-Host "✅ $result" -ForegroundColor Green
    }
}

# Check if any files were downloaded
$downloads = Get-ChildItem -Path "./cat-education-videos" -Recurse -Include "*.mp4" -ErrorAction SilentlyContinue
if ($downloads.Count -gt 0) {
    Write-Host ""
    Write-Host "🎉 Successfully downloaded $($downloads.Count) videos!" -ForegroundColor Green
    $downloads | ForEach-Object { Write-Host "  📹 $($_.Name)" -ForegroundColor Gray }
} else {
    Write-Host ""
    Write-Host "💡 Recommendations:" -ForegroundColor Cyan
    Write-Host "- TikTok requires session cookies for reliable access" -ForegroundColor Gray
    Write-Host "- Try the session-based download: .\download-with-session.ps1" -ForegroundColor Gray
    Write-Host "- US IP helped (no more 403 on trending), but need authentication" -ForegroundColor Gray
}