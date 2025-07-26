# FiReferral - Fiber Internet Referral Management System

A comprehensive Flutter application for managing fiber internet referrals with organization-based multi-tenancy, commission tracking, and secure data isolation.

## 🚀 Features

### 🏢 Multi-Tenant Architecture
- **Organization-Based Isolation**: Complete data separation between organizations
- **Secure Multi-Tenancy**: Each organization operates independently with no cross-data access
- **Organization-Specific Settings**: Custom branding, themes, and configurations per organization

### 👥 User Management
- **Role-Based Access Control**: Admin, Associate, and Affiliate user roles
- **Hierarchical Structure**: Associates manage affiliates within their organization
- **Secure Authentication**: Firebase Authentication with organization-specific user management

### 📊 Referral Management
- **Complete Referral Lifecycle**: From submission to payment tracking
- **Status Management**: Submitted → Under Review → Approved → Scheduled → Installed → Paid
- **Commission Tracking**: Automated commission calculations and payment tracking
- **Real-time Updates**: Live status updates and notifications

### 📈 Analytics & Reporting
- **Comprehensive Dashboard**: Organization-specific analytics and insights
- **Performance Metrics**: Conversion rates, commission totals, and referral statistics
- **Visual Charts**: Interactive charts for data visualization
- **Export Capabilities**: Data export for reporting and analysis

### 🎨 Customization
- **Organization Branding**: Custom logos, company names, and color schemes
- **Theme Management**: Multiple theme options with dark/light mode support
- **Responsive Design**: Optimized for mobile, tablet, and desktop

## 🏗️ Architecture

### Backend Services
- **Firebase Authentication**: Secure user authentication and session management
- **Cloud Firestore**: NoSQL database with real-time synchronization
- **Organization Service**: Manages organization creation and settings
- **Referral Service**: Handles referral lifecycle and data management
- **Auth Service**: User management and role-based access control

### Frontend Structure
- **Provider Pattern**: State management using Provider for reactive UI
- **Modular Design**: Organized by features with clear separation of concerns
- **Responsive UI**: Adaptive layouts for different screen sizes
- **Material Design**: Modern UI following Material Design principles

### Security Features
- **Data Isolation**: Complete separation of data between organizations
- **Role-Based Permissions**: Granular access control based on user roles
- **Secure API Calls**: All database operations filtered by organization ID
- **Input Validation**: Comprehensive validation and sanitization

## 🛠️ Technical Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: Provider Pattern
- **UI Framework**: Material Design 3
- **Charts**: FL Chart for data visualization
- **Navigation**: GoRouter for declarative routing

## 📱 User Roles & Permissions

### 🔑 Admin
- Full organization management
- User creation and management
- Analytics and reporting access
- Commission settings configuration
- Organization branding customization

### 👔 Associate
- Manage assigned affiliates
- View team performance
- Access to team analytics
- Referral oversight and approval

### 🤝 Affiliate
- Submit new referrals
- Track referral status
- View personal performance
- Commission tracking

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shiferaxa/fireferral-0.0
   cd fireferral
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Download and add configuration files:
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
     - `web/firebase-config.js` (Web)

4. **Configure Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Security Rules

Update your Firestore security rules to ensure proper data isolation:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own organization's data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
    
    // Organization-specific referrals
    match /referrals/{referralId} {
      allow read, write: if request.auth != null && 
        resource.data.organizationId == getUserOrganization();
    }
    
    // Organization settings
    match /organization_settings/{orgId} {
      allow read, write: if request.auth != null && 
        orgId == getUserOrganization();
    }
    
    function getUserOrganization() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.organizationId;
    }
  }
}
```

### Environment Variables

Create a `.env` file for environment-specific configurations:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-auth-domain
```

## 📊 Database Schema

### Collections Structure

```
├── organizations/
│   ├── {orgId}/
│   │   ├── name: string
│   │   ├── createdAt: timestamp
│   │   ├── createdBy: string
│   │   └── isActive: boolean
│
├── users/
│   ├── {userId}/
│   │   ├── email: string
│   │   ├── firstName: string
│   │   ├── lastName: string
│   │   ├── role: string
│   │   ├── organizationId: string
│   │   └── isActive: boolean
│
├── referrals/
│   ├── {referralId}/
│   │   ├── submittedBy: string
│   │   ├── organizationId: string
│   │   ├── customer: object
│   │   ├── status: string
│   │   ├── commissionAmount: number
│   │   └── submittedAt: timestamp
│
└── organization_settings/
    ├── {orgId}/
    │   ├── companyName: string
    │   ├── companyLogo: string
    │   ├── themeType: number
    │   └── isDarkMode: boolean
```

## 🔒 Security Features

- **Organization Isolation**: Complete data separation between organizations
- **Role-Based Access**: Granular permissions based on user roles
- **Secure Authentication**: Firebase Authentication with custom claims
- **Data Validation**: Input validation and sanitization
- **API Security**: All queries filtered by organization ID

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

## 📦 Build & Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the Firebase setup guide

## 🔄 Recent Updates

### v1.0.0 - Multi-Tenant Security Release
- ✅ Implemented organization-based multi-tenancy
- ✅ Fixed cross-organization data leakage
- ✅ Added secure organization settings
- ✅ Improved user signup flow
- ✅ Enhanced Firebase security rules
- ✅ Added comprehensive error handling

---

**FiReferral** - Empowering organizations with secure, scalable referral management.
