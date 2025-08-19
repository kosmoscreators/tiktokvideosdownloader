# TikTok Scraper Deployment Guide

This guide covers how to deploy and use the TikTok scraper in different environments.

## Prerequisites

- Node.js 18+ (for local deployment)
- Docker (for containerized deployment - optional)
- Git

## Quick Start (Recommended)

### Windows PowerShell

**Local Deployment (Recommended):**
```powershell
.\deploy-local.ps1
```

**Docker Deployment:**
```powershell
.\deploy.ps1
```

### If Docker Build Fails

If you encounter Docker Hub connectivity issues, try:

1. **Use local deployment instead:**
   ```powershell
   .\deploy-local.ps1
   ```

2. **Use offline Docker build (if you have cached images):**
   ```powershell
   .\docker-build-offline.ps1
   ```

3. **Fix network connectivity:**
   - Check internet connection
   - Restart Docker Desktop
   - Configure proxy settings if behind corporate firewall

## Local Deployment (Manual)

1. **Install dependencies:**
   ```bash
   npm install --legacy-peer-deps
   ```

2. **Build the project:**
   ```bash
   npm run build
   ```

3. **Install globally:**
   ```bash
   npm link
   ```

4. **Test the installation:**
   ```bash
   tiktok-scraper --help
   ```

## Docker Deployment (Manual)

### When Network is Available

1. **Build manually:**
   ```bash
   docker build -t tiktok-scraper .
   ```

2. **Run with Docker:**
   ```bash
   # Show help
   docker run --rm -v "$(pwd)/downloads:/usr/app/files" tiktok-scraper --help
   
   # Scrape user feed
   docker run --rm -v "$(pwd)/downloads:/usr/app/files" tiktok-scraper user USERNAME -n 10 -d -t json
   ```

### Using Docker Compose

1. **Start the scraper:**
   ```bash
   docker-compose up tiktok-scraper
   ```

2. **Run specific examples:**
   ```bash
   # User scraping
   docker-compose up tiktok-user
   
   # Hashtag scraping
   docker-compose up tiktok-hashtag
   ```

## Usage Examples

### CLI Commands

```bash
# Scrape user posts
tiktok-scraper user USERNAME -n 100 -d -t json

# Scrape hashtag posts
tiktok-scraper hashtag HASHTAG -n 50 -d -t csv

# Scrape trending posts
tiktok-scraper trend -n 20 -d

# Download single video
tiktok-scraper video "https://www.tiktok.com/@user/video/123456789" -d

# View download history
tiktok-scraper history
```

### Using Sessions (for better success rates)

```bash
tiktok-scraper user USERNAME -n 10 --session "sid_tt=your_session_cookie" -d -t json
```

To get session cookie:
1. Open https://www.tiktok.com in browser
2. Login to your account
3. Open Developer Tools → Network tab
4. Find any request → Headers → Cookie
5. Copy the `sid_tt` value

## Important Notes

- **Rate Limiting**: TikTok implements rate limiting. Use proxies or sessions for better success rates
- **Captcha**: If requests are blocked, try using `--useTestEndpoints` flag
- **File Downloads**: Videos will be saved to the specified directory (default: current directory)
- **History**: The scraper tracks download history to avoid duplicates when using `-s` flag

## Troubleshooting

1. **Build Failures**: Ensure you have Python and build tools installed
2. **Canvas Issues**: Canvas dependency was removed for Windows compatibility
3. **Request Blocked**: Use sessions, proxies, or test endpoints
4. **Old Dependencies**: Run with `--legacy-peer-deps` flag

## Security Note

This scraper is for educational and research purposes only. Respect TikTok's terms of service and rate limits. Do not use for malicious purposes.