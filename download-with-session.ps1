#!/usr/bin/env powershell

param(
    [Parameter(Mandatory=$true)]
    [string]$SessionCookie
)

Write-Host "Cat Education Video Downloader (With Session)" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

if (-not $SessionCookie.StartsWith("sid_tt=")) {
    Write-Host "Error: Session cookie should start with 'sid_tt='" -ForegroundColor Red
    Write-Host "Example: .\download-with-session.ps1 'sid_tt=abc123def456;'" -ForegroundColor Yellow
    exit 1
}

Write-Host "Using session: $($SessionCookie.Substring(0, 20))..." -ForegroundColor Cyan

# Create directory for videos
$videoDir = "cat-education-videos"
if (!(Test-Path $videoDir)) {
    New-Item -ItemType Directory -Path $videoDir
    Write-Host "Created directory: $videoDir" -ForegroundColor Yellow
}

# Educational hashtags for cat care
$categories = @{
    "Basic Care" = @("catcare", "cattips", "catbasics")
    "Health" = @("cathealth", "catvet", "catillness")
    "Behavior" = @("catbehavior", "cattraining", "catbody")
    "First Time" = @("firstcat", "newcatowner", "catowner101")
}

$totalDownloaded = 0
$targetTotal = 10

Write-Host ""
Write-Host "Starting educational video download..." -ForegroundColor Blue
Write-Host "Target: $targetTotal videos for cat education" -ForegroundColor Blue
Write-Host ""

foreach ($category in $categories.Keys) {
    if ($totalDownloaded -ge $targetTotal) { break }
    
    Write-Host "Category: $category" -ForegroundColor Magenta
    Write-Host "$(('-' * $category.Length))" -ForegroundColor Magenta
    
    $hashtags = $categories[$category]
    
    foreach ($hashtag in $hashtags) {
        if ($totalDownloaded -ge $targetTotal) { break }
        
        $remaining = $targetTotal - $totalDownloaded
        $toDownload = [Math]::Min(2, $remaining)
        
        Write-Host "  Downloading from #$hashtag ($toDownload videos)..." -ForegroundColor Cyan
        
        try {
            $result = & tiktok-scraper hashtag $hashtag -n $toDownload -d -w -t json --session $SessionCookie --timeout 3000 --filepath "./$videoDir" --filename "$category-$hashtag" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    ✅ Success!" -ForegroundColor Green
                $totalDownloaded += $toDownload
                
                # Check for actual downloaded files
                $newFiles = Get-ChildItem -Path $videoDir -Recurse -Include "*.mp4" -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -gt (Get-Date).AddMinutes(-2) }
                if ($newFiles.Count -gt 0) {
                    Write-Host "    📁 Downloaded $($newFiles.Count) video file(s)" -ForegroundColor Green
                }
            } else {
                Write-Host "    ❌ Failed: $result" -ForegroundColor Red
            }
        } catch {
            Write-Host "    ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Delay between requests to avoid rate limiting
        Start-Sleep -Seconds 3
    }
    
    Write-Host "  Total downloaded so far: $totalDownloaded" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "Final Results:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan

# Check actual downloaded files
$allVideoFiles = Get-ChildItem -Path $videoDir -Recurse -Include "*.mp4" -ErrorAction SilentlyContinue
$allJsonFiles = Get-ChildItem -Path $videoDir -Recurse -Include "*.json" -ErrorAction SilentlyContinue

if ($allVideoFiles.Count -gt 0) {
    Write-Host "✅ Successfully downloaded $($allVideoFiles.Count) video files" -ForegroundColor Green
    Write-Host "✅ Generated $($allJsonFiles.Count) metadata files" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files saved in: $videoDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Educational content categories covered:" -ForegroundColor White
    
    $categories.Keys | ForEach-Object {
        $categoryFiles = $allVideoFiles | Where-Object { $_.DirectoryName -like "*$_*" }
        if ($categoryFiles.Count -gt 0) {
            Write-Host "  📚 $_`: $($categoryFiles.Count) videos" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "- Review videos for educational appropriateness" -ForegroundColor Gray
    Write-Host "- Check metadata files for creator information" -ForegroundColor Gray
    Write-Host "- Organize by difficulty level (beginner, intermediate)" -ForegroundColor Gray
    Write-Host "- Consider giving credit to original creators" -ForegroundColor Gray
    
} else {
    Write-Host "❌ No videos were downloaded" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible issues:" -ForegroundColor Yellow
    Write-Host "- Session cookie may be invalid or expired" -ForegroundColor Gray
    Write-Host "- TikTok may still be blocking requests" -ForegroundColor Gray
    Write-Host "- Network connectivity issues" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Cyan
    Write-Host "- Getting a fresh session cookie" -ForegroundColor Gray
    Write-Host "- Using a different network/VPN" -ForegroundColor Gray
    Write-Host "- Trying individual video URLs instead of hashtags" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Session download attempt completed!" -ForegroundColor Green