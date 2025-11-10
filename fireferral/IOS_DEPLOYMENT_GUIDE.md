# 📱 iOS Deployment Guide - FiReferral

## ✅ **Current Status**
- ✅ **Bundle ID**: `com.fireferral.app`
- ✅ **Display Name**: FiReferral
- ✅ **Firebase**: Configured
- ✅ **Google OAuth**: Configured
- ✅ **Xcode Project**: Ready
- ⏳ **Code Signing**: Needs Apple Developer Account

## 🔐 **Step 1: Apple Developer Account Setup**

### **Sign in to Xcode**
1. Open **Xcode > Settings > Accounts**
2. Click **"+"** and select **"Apple ID"**
3. Sign in with your Apple Developer account
4. Verify your team appears in the list

### **Configure Project Signing**
1. In Xcode project navigator, select **"Runner"** (blue icon)
2. Select **"Runner"** target under TARGETS
3. Go to **"Signing & Capabilities"** tab
4. ✅ Check **"Automatically manage signing"**
5. Select your **Development Team** from dropdown
6. Verify **Bundle Identifier**: `com.fireferral.app`

## 📱 **Step 2: Device Registration**

### **For Physical Device Testing**
1. Connect your iPhone/iPad via USB
2. In Xcode, go to **Window > Devices and Simulators**
3. Select your device and click **"Use for Development"**
4. Trust the developer certificate on your device:
   - **Settings > General > VPN & Device Management**
   - Tap your developer profile and **"Trust"**

### **For App Store Distribution**
1. Register devices in **Apple Developer Portal**
2. Create **Distribution Certificate**
3. Create **App Store Provisioning Profile**

## 🚀 **Step 3: Build and Deploy**

### **Simulator Testing** (No signing required)
```bash
# Run on iPhone simulator
flutter run -d 'iPhone 16 Pro'

# Build for simulator
flutter build ios --simulator
```

### **Device Testing** (Requires signing)
```bash
# Run on connected device
flutter run -d 'Your iPhone Name'

# Build for device
flutter build ios --release
```

### **App Store Deployment**
```bash
# Build for App Store
flutter build ios --release

# Archive in Xcode
# 1. Open ios/Runner.xcworkspace
# 2. Product > Archive
# 3. Upload to App Store Connect
```

## 📋 **App Store Submission Checklist**

### **Required Assets**
- [ ] App Icon (1024x1024px)
- [ ] Screenshots for all device sizes
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Support URL

### **App Store Connect Setup**
1. Create app in **App Store Connect**
2. Set **Bundle ID**: `com.fireferral.app`
3. Upload build via **Xcode Organizer**
4. Fill out app information
5. Submit for review

## 🔧 **Configuration Files**

### **Bundle Identifier**
- **iOS**: `com.fireferral.app`
- **Android**: `com.fireferral.app`

### **Firebase Configuration**
- **iOS**: `ios/Runner/GoogleService-Info.plist`
- **Android**: `android/app/google-services.json`

### **Google OAuth**
- **Web Client ID**: Configured in Firebase
- **iOS URL Scheme**: `com.googleusercontent.apps.2371357998-9iqt6v0ek0gb2f8snurf6laq0du2o5ar`

## 🧪 **Testing Checklist**

### **Simulator Testing**
- [ ] App launches successfully
- [ ] Firebase authentication works
- [ ] Google Sign-In works
- [ ] All screens navigate properly
- [ ] Commission settings save
- [ ] Referral submission works

### **Device Testing**
- [ ] Push notifications (if implemented)
- [ ] Camera/photo picker
- [ ] Network connectivity
- [ ] Background app refresh
- [ ] Performance on older devices

## 🎯 **Current App Features**

- ✅ **User Authentication** (Email/Password + Google OAuth)
- ✅ **Referral Management** (Submit, track, manage)
- ✅ **Commission Settings** (Admin configuration)
- ✅ **User Management** (Admin panel)
- ✅ **Analytics Dashboard** (Performance tracking)
- ✅ **Multi-tenant Support** (Organization isolation)
- ✅ **Responsive Design** (Works on all iOS devices)

## 🔒 **Security Features**

- ✅ **Firebase Security Rules** (Role-based access)
- ✅ **Data Encryption** (Firebase handles this)
- ✅ **Secure Authentication** (Firebase Auth)
- ✅ **API Key Protection** (Not exposed in client)

## 📞 **Support Information**

- **App Name**: FiReferral
- **Bundle ID**: com.fireferral.app
- **Version**: 1.0.0+1
- **Minimum iOS**: 12.0
- **Supported Devices**: iPhone, iPad
- **Orientations**: Portrait, Landscape

Your iOS app is ready for deployment! 🎉