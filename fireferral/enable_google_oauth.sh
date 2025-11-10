#!/bin/bash

# Enable Google OAuth Script
# Run this after configuring OAuth credentials in Google Cloud Console

echo "🔧 Enabling Google OAuth Sign-In"
echo "================================="

# Check if client ID is provided
if [ $# -ne 1 ]; then
    echo "❌ Usage: $0 <WEB_CLIENT_ID>"
    echo ""
    echo "Example:"
    echo "$0 '123456789-abcdef.apps.googleusercontent.com'"
    echo ""
    echo "Get this from Google Cloud Console > APIs & Services > Credentials"
    exit 1
fi

WEB_CLIENT_ID="$1"

echo "📝 Updating configuration files..."

# Update web/index.html
echo "🌐 Updating web configuration..."
sed -i '' "s/2371357998-placeholder\.apps\.googleusercontent\.com/$WEB_CLIENT_ID/g" web/index.html

# Enable Google Sign-In in login screen
echo "📱 Enabling Google Sign-In in app..."
sed -i '' 's/\/\/ Show configuration message until OAuth is properly set up/setState(() {\
      _isLoading = true;\
    });\
\
    final authProvider = Provider.of<AuthProvider>(context, listen: false);\
    final success = await authProvider.signInWithGoogle();\
\
    setState(() {\
      _isLoading = false;\
    });\
\
    if (!success \&\& mounted) {\
      final scaffoldMessenger = ScaffoldMessenger.of(context);\
      final theme = Theme.of(context);\
      \
      String errorMessage = authProvider.errorMessage ?? '\''Google sign in failed'\'';\
      \
      \/\/ Check if the error is about account not found\
      if (errorMessage.contains('\''Account not found'\'') || errorMessage.contains('\''complete the signup process'\'')) {\
        \/\/ Show a more helpful message and option to go to signup\
        showDialog(\
          context: context,\
          builder: (context) => AlertDialog(\
            title: const Text('\''Account Not Found'\''),\
            content: const Text(\
              '\''No account found with this Google account. Would you like to create a new account?'\''\
            ),\
            actions: [\
              TextButton(\
                onPressed: () => Navigator.of(context).pop(),\
                child: const Text('\''Cancel'\''),\
              ),\
              ElevatedButton(\
                onPressed: () {\
                  Navigator.of(context).pop();\
                  context.go('\''/signup'\'');\
                },\
                child: const Text('\''Create Account'\''),\
              ),\
            ],\
          ),\
        );\
      } else {\
        \/\/ Show regular error message\
        scaffoldMessenger.showSnackBar(\
          SnackBar(\
            content: Text(errorMessage),\
            backgroundColor: theme.colorScheme.error,\
            action: SnackBarAction(\
              label: '\''Retry'\'',\
              textColor: Colors.white,\
              onPressed: _handleGoogleSignIn,\
            ),\
          ),\
        );\
      }\
    }\
    \
    \/\/ Show configuration message until OAuth is properly set up/g' lib/screens/auth/login_screen.dart

echo ""
echo "✅ Google OAuth enabled successfully!"
echo ""
echo "📋 Summary:"
echo "  Web Client ID: $WEB_CLIENT_ID"
echo "  Android Package: com.fireferral.app"
echo "  SHA-1 Fingerprint: 37:76:90:C5:EE:B9:5E:10:76:86:D9:F4:73:25:8D:37:ED:A4:C5:66"
echo ""
echo "🔄 Next steps:"
echo "  1. flutter build web --release"
echo "  2. firebase deploy --only hosting"
echo "  3. Test Google Sign-In at https://fireferral.web.app"
echo ""
echo "🧪 To test locally:"
echo "  flutter run -d chrome --web-port 8081"