# 🔐 Security Setup Guide

This document outlines the security configuration needed for the FiReferral app.

## ⚠️ IMPORTANT: Sensitive Files

The following files contain sensitive information and should NOT be committed to public repositories:

### 🔥 Firebase Configuration Files
- `android/app/google-services.json` - Contains Android API keys
- `ios/Runner/GoogleService-Info.plist` - Contains iOS API keys
- `web/index.html` - Contains Web Client ID (currently templated)

### 📋 Setup Instructions

1. **Download Firebase Configuration Files**:
   - Go to [Firebase Console](https://console.firebase.google.com/project/fireferral)
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the correct directories

2. **Update Web Client ID**:
   - Get your Web Client ID from Google Cloud Console
   - Replace `YOUR_WEB_CLIENT_ID` in `web/index.html`

3. **Verify .gitignore**:
   - Ensure sensitive files are listed in `.gitignore`
   - Never commit actual configuration files to version control

## 🛡️ Current Security Status

### ✅ Safe for GitHub:
- All source code files
- Template configuration files
- Security rules
- Documentation
- Build configurations (without secrets)

### ❌ NOT Safe for GitHub:
- `android/app/google-services.json` (contains API keys)
- `ios/Runner/GoogleService-Info.plist` (contains API keys)
- Any `.env` files
- `users.json` or other exported data

## 🔧 Local Development Setup

1. Copy template files:
   ```bash
   cp android/app/google-services.json.template android/app/google-services.json
   cp ios/Runner/GoogleService-Info.plist.template ios/Runner/GoogleService-Info.plist
   ```

2. Replace placeholders with actual values from Firebase Console

3. Update web client ID in `web/index.html`

## 📊 API Keys Found (for reference):

### Android API Key:
- Location: `android/app/google-services.json`
- Key: `AIzaSyAbLV7b4Y59psn9eUEJspWwdAPgC_mTOtw`
- Status: ⚠️ Should be kept private

### iOS API Key:
- Location: `ios/Runner/GoogleService-Info.plist`
- Key: `AIzaSyAqdWDM_JfuLc5-ElrJqqIfpR7oq39KhEk`
- Status: ⚠️ Should be kept private

### Web Client ID:
- Location: `web/index.html`
- ID: `2371357998-9iqt6v0ek0gb2f8snurf6laq0du2o5ar.apps.googleusercontent.com`
- Status: ⚠️ Should be kept private

### Project Information:
- Project ID: `fireferral`
- Project Number: `2371357998`
- Package Name: `com.fireferral.app`

## 🚀 Deployment Notes

- The app is configured for production deployment
- All sensitive data should be managed through environment variables or secure configuration management
- Firebase security rules are properly configured and can be safely committed