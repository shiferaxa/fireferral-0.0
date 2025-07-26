#!/bin/bash

# Firebase Security Rules Testing Script
# This script validates security rules locally

echo "🧪 Firebase Security Rules Testing"
echo "=================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

echo "🔍 Testing Firestore rules..."
if firebase firestore:rules:validate firestore.rules; then
    echo "✅ Firestore rules are valid!"
else
    echo "❌ Firestore rules validation failed!"
    exit 1
fi

echo ""
echo "🔍 Testing Storage rules..."
if firebase storage:rules:validate storage.rules; then
    echo "✅ Storage rules are valid!"
else
    echo "❌ Storage rules validation failed!"
    exit 1
fi

echo ""
echo "🎉 All security rules are valid!"
echo ""
echo "🚀 To deploy these rules, run:"
echo "   ./deploy_security_rules.sh"
echo ""
echo "🧪 To test with emulator, run:"
echo "   firebase emulators:start --only firestore,storage"