#!/bin/bash

# Firebase Security Rules Deployment Script
# This script deploys both Firestore and Storage security rules

echo "🔐 Firebase Security Rules Deployment"
echo "====================================="

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run:"
    echo "   firebase login"
    exit 1
fi

# Get current project
PROJECT=$(firebase use --json | jq -r '.result.current // empty')
if [ -z "$PROJECT" ]; then
    echo "❌ No Firebase project selected. Please run:"
    echo "   firebase use <project-id>"
    exit 1
fi

echo "📋 Current project: $PROJECT"
echo ""

# Validate rules syntax
echo "🔍 Validating Firestore rules..."
if ! firebase firestore:rules:validate firestore.rules; then
    echo "❌ Firestore rules validation failed!"
    exit 1
fi

echo "🔍 Validating Storage rules..."
if ! firebase storage:rules:validate storage.rules; then
    echo "❌ Storage rules validation failed!"
    exit 1
fi

echo "✅ All rules validated successfully!"
echo ""

# Ask for confirmation
read -p "🚀 Deploy security rules to $PROJECT? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

echo ""
echo "🚀 Deploying security rules..."

# Deploy Firestore rules
echo "📊 Deploying Firestore rules..."
if firebase deploy --only firestore:rules; then
    echo "✅ Firestore rules deployed successfully!"
else
    echo "❌ Firestore rules deployment failed!"
    exit 1
fi

# Deploy Storage rules
echo "📁 Deploying Storage rules..."
if firebase deploy --only storage; then
    echo "✅ Storage rules deployed successfully!"
else
    echo "❌ Storage rules deployment failed!"
    exit 1
fi

echo ""
echo "🎉 Security rules deployment completed!"
echo ""
echo "📋 Summary:"
echo "  ✅ Firestore rules: Deployed"
echo "  ✅ Storage rules: Deployed"
echo "  🔗 Project: $PROJECT"
echo ""
echo "🔍 Next steps:"
echo "  1. Test the rules with your app"
echo "  2. Monitor Firebase console for any issues"
echo "  3. Check security rule usage in Firebase console"
echo ""
echo "📚 Documentation: FIREBASE_SECURITY_RULES.md"