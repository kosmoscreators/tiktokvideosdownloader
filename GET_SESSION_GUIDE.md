# How to Get TikTok Session Cookie for Better Success Rate

When TikTok blocks requests (403 Forbidden), using a valid session cookie can help bypass these restrictions.

## Steps to Get Session Cookie:

### Method 1: Browser Developer Tools

1. **Open TikTok in your browser:**
   - Go to https://www.tiktok.com
   - Log into your TikTok account

2. **Open Developer Tools:**
   - Press `F12` or right-click → "Inspect"
   - Go to the **Network** tab

3. **Refresh the page:**
   - Press `F5` to refresh TikTok page
   - Look for any request in the Network tab

4. **Find Cookie:**
   - Click on any request to TikTok
   - Go to **Request Headers** section
   - Find the **Cookie** line
   - Look for `sid_tt=` followed by a long string

5. **Copy the session:**
   - Copy the entire `sid_tt=XXXXX;` part
   - Example: `sid_tt=521kkadkasdaskdj4j213j12j312;`

### Method 2: Browser Console

1. **Open TikTok and login**
2. **Open Console** (`F12` → Console tab)
3. **Run this command:**
   ```javascript
   document.cookie.split(';').find(c => c.includes('sid_tt'))
   ```
4. **Copy the result**

## Using the Session Cookie:

Once you have the session cookie, use it with the scraper:

```bash
# Example with session cookie
tiktok-scraper hashtag cats -n 5 -d -w -t json --session "sid_tt=YOUR_SESSION_HERE;" --filepath ./cat-education-videos
```

## Alternative Methods if Sessions Don't Work:

### 1. Use Proxy Servers
```bash
tiktok-scraper hashtag cats -n 5 -d -w --proxy "http://proxy-server:port"
```

### 2. Use Proxy File
Create a file `proxies.txt` with one proxy per line:
```
http://proxy1:port
socks5://proxy2:port
http://proxy3:port
```

Then use:
```bash
tiktok-scraper hashtag cats -n 5 -d -w --proxy-file proxies.txt
```

### 3. Try Different Hashtags
- Use less popular hashtags
- Try single words instead of compound words
- Use hashtags in different languages

### 4. Download Individual Videos
If you can find specific TikTok video URLs, you can download them directly:
```bash
tiktok-scraper video "https://www.tiktok.com/@username/video/1234567890" -d -w
```

## Best Practices:

1. **Don't overload:** Use small numbers (-n 5 instead of -n 100)
2. **Add delays:** Use --timeout 2000 for 2-second delays between requests
3. **Use sessions:** Always try to use valid session cookies
4. **Rotate proxies:** Use multiple proxies if you have them
5. **Try different times:** TikTok's blocking may vary by time of day

## Legal and Ethical Notes:

- Only download videos for educational, research, or fair use purposes
- Respect content creators' rights
- Don't download copyrighted content for commercial use
- Follow TikTok's terms of service
- Consider reaching out to creators for permission when possible