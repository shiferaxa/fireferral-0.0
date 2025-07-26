#!/bin/bash

# Google OAuth Configuration Update Script
# Run this script after getting your OAuth client IDs from Google Cloud Console

echo "🔧 Google OAuth Configuration Update Script"
echo "============================================="

# Check if client IDs are provided
if [ $# -ne 2 ]; then
    echo "❌ Usage: $0 <WEB_CLIENT_ID> <IOS_URL_SCHEME>"
    echo ""
    echo "Example:"
    echo "$0 '123456789-abcdef.apps.googleusercontent.com' 'com.googleusercontent.apps.123456789-abcdef'"
    echo ""
    echo "Get these values from Google Cloud Console > APIs & Services > Credentials"
    exit 1
fi

WEB_CLIENT_ID="$1"
IOS_URL_SCHEME="$2"

echo "📝 Updating configuration files..."

# Update web/index.html
echo "🌐 Updating web configuration..."
sed -i '' "s/2371357998-placeholder\.apps\.googleusercontent\.com/$WEB_CLIENT_ID/g" web/index.html

# Update iOS GoogleService-Info.plist
echo "📱 Updating iOS GoogleService-Info.plist..."
sed -i '' "s/com\.googleusercontent\.apps\.2371357998-placeholder/$IOS_URL_SCHEME/g" ios/Runner/GoogleService-Info.plist

# Update iOS Info.plist
echo "📱 Updating iOS Info.plist..."
sed -i '' "s/com\.googleusercontent\.apps\.2371357998-placeholder/$IOS_URL_SCHEME/g" ios/Runner/Info.plist

echo ""
echo "✅ Configuration updated successfully!"
echo ""
echo "📋 Summary:"
echo "  Web Client ID: $WEB_CLIENT_ID"
echo "  iOS URL Scheme: $IOS_URL_SCHEME"
echo ""
echo "🔄 Next steps:"
echo "  1. Re-enable Google Sign-In in lib/screens/auth/login_screen.dart"
echo "  2. Test the app on both web and iOS"
echo "  3. Commit the changes to version control"
echo ""
echo "🧪 To test:"
echo "  flutter run -d chrome --web-port 8081"
echo "  flutter run -d 'iPhone 16 Pro'"