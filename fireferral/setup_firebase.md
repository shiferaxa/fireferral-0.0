# Firebase Setup Instructions

Your Firebase project "fireferral" is now connected to your Flutter app! Here's what you need to do to complete the setup:

## 1. Enable Authentication
1. Go to [Firebase Console](https://console.firebase.google.com/project/fireferral)
2. Click on "Authentication" in the left sidebar
3. Click "Get started"
4. Go to the "Sign-in method" tab
5. Enable "Email/Password" authentication
6. Click "Save"

## 2. Enable Firestore Database
1. In the Firebase Console, click on "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (we'll secure it later)
4. Select a location (choose the one closest to your users)
5. Click "Done"

## 3. Enable Storage (for company logos)
1. Click on "Storage" in the left sidebar
2. Click "Get started"
3. Choose "Start in test mode"
4. Select the same location as your Firestore
5. Click "Done"

## 4. Set up Firestore Security Rules
Once you've created the database, replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Admins can read all users
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      // Admins can create new users
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Referrals
    match /referrals/{referralId} {
      // Users can read their own referrals
      allow read: if request.auth != null && 
        (resource.data.submittedBy == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      
      // Users can create referrals
      allow create: if request.auth != null && 
        request.resource.data.submittedBy == request.auth.uid;
      
      // Only admins can update referrals
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Fiber packages (admin only)
    match /packages/{packageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 5. Set up Storage Security Rules
Replace the default storage rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Company logos (admin only)
    match /company/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // User uploads
    match /uploads/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 6. Test Your Setup
1. Run your Flutter app: `flutter run -d web-server --web-port 8081`
2. Try to create an admin account using the signup form
3. Sign in with your new admin account
4. Check the Firebase Console to see if the user was created in Authentication and Firestore

## Your Firebase Configuration
- Project ID: `fireferral`
- Web App ID: `1:2371357998:web:b8f4456cae0358950dbebf`
- Android App ID: `1:2371357998:android:29b3c7ba3587d1d20dbebf`
- iOS App ID: `1:2371357998:ios:35ba055bca38bdca0dbebf`

## Next Steps
Once Firebase is fully configured, you can:
1. Create your first admin account
2. Set up company branding
3. Create associate and affiliate accounts
4. Start tracking referrals!

The app is now connected to your Firebase project and ready to use!