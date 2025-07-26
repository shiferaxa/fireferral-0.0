# Google OAuth Setup Guide

## Step 1: Access Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your `fireferral` project (or create one if it doesn't exist)

## Step 2: Enable Required APIs

1. Go to **APIs & Services > Library**
2. Search for and enable these APIs:
   - **Google Sign-In API**
   - **Google Identity Services API**
   - **Firebase Authentication API** (if not already enabled)

## Step 3: Create OAuth 2.0 Client IDs

### For Web Application:
1. Go to **APIs & Services > Credentials**
2. Click **+ CREATE CREDENTIALS > OAuth 2.0 Client IDs**
3. Choose **Web application**
4. Name: `Fireferral Web Client`
5. **Authorized JavaScript origins:**
   - `http://localhost:8081` (for development)
   - `https://your-domain.com` (for production)
6. **Authorized redirect URIs:**
   - `http://localhost:8081` (for development)
   - `https://your-domain.com` (for production)
7. Click **CREATE**
8. **Copy the Client ID** (format: `xxxxx-xxxxx.apps.googleusercontent.com`)

### For iOS Application:
1. Click **+ CREATE CREDENTIALS > OAuth 2.0 Client IDs** again
2. Choose **iOS**
3. Name: `Fireferral iOS Client`
4. **Bundle ID:** `com.example.fireferral` (must match your iOS app)
5. Click **CREATE**
6. **Copy both:**
   - **Client ID** (format: `xxxxx-xxxxx.apps.googleusercontent.com`)
   - **iOS URL scheme** (format: `com.googleusercontent.apps.xxxxx-xxxxx`)

## Step 4: Update Configuration Files

### Update Web Configuration:
Replace the placeholder in `web/index.html`:
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID_HERE">
```

### Update iOS Configuration:
1. Replace in `ios/Runner/GoogleService-Info.plist`:
```xml
<key>REVERSED_CLIENT_ID</key>
<string>YOUR_IOS_URL_SCHEME_HERE</string>
```

2. Replace in `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>YOUR_IOS_URL_SCHEME_HERE</string>
</array>
```

## Step 5: Test the Setup

1. Update the configuration files with real client IDs
2. Re-enable Google Sign-In in the login screen
3. Test on both web and iOS

## Important Notes:

- **Client IDs are public** - they can be safely committed to version control
- **Bundle ID must match** exactly between Google Cloud Console and iOS app
- **Domain verification** may be required for production web domains
- **Test thoroughly** on both platforms before deploying

## Troubleshooting:

- **"OAuth client not found"**: Check client ID is correct and copied fully
- **"Unauthorized domain"**: Add your domain to authorized origins
- **iOS not working**: Verify bundle ID matches exactly
- **Web not working**: Check authorized JavaScript origins include your domain