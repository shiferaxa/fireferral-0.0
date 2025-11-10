# FireReferral Restructure Summary

## Overview
FireReferral has been restructured from a multi-organization system to a single-admin (Invision) system where properties can submit referrals.

## Key Changes

### 1. User Roles
**Before:**
- `admin` - Organization administrators
- `associate` - Sales associates
- `affiliate` - Affiliates under associates

**After:**
- `invisionAdmin` - Single Invision administrator (only ONE can exist)
- `property` - Property accounts that submit referrals to Invision

### 2. User Model Changes
**Removed Fields:**
- `organizationId` - No longer needed (single organization)
- `associateId` - No longer needed (flat structure)

**Added Fields:**
- `propertyName` - Name of the property
- `propertyAddress` - Address of the property

### 3. Access Control

#### Invision Admin Can:
- ✅ View all statistics and analytics
- ✅ Create property accounts
- ✅ View all referrals from all properties
- ✅ Manage commissions
- ✅ Deactivate/activate property accounts
- ✅ Reset property passwords
- ✅ Access full admin dashboard

#### Property Accounts Can ONLY:
- ✅ Submit referrals to Invision
- ✅ View their own submitted referrals
- ✅ Manage their profile
- ❌ **NO access to statistics**
- ❌ **NO access to analytics**
- ❌ **NO access to earnings data**
- ❌ **NO access to conversion rates**
- ❌ **NO access to other properties' data**
- ❌ **NO access to insider information**

### 4. New Screens

#### `InvisionSetupScreen`
- One-time setup screen for creating the Invision admin account
- Only accessible if no admin exists
- Prevents multiple admin accounts

#### `PropertyDashboardScreen`
- Simplified dashboard for property accounts
- Shows:
  - Welcome message with property name
  - Submit referral button
  - View my referrals button
  - Profile management
- **Does NOT show:**
  - Statistics
  - Analytics
  - Earnings
  - Conversion rates
  - Any insider information

#### `CreatePropertyScreen`
- Admin-only screen to create property accounts
- Collects:
  - Property name and address
  - Contact person information
  - Login credentials
- Only accessible by Invision admin

#### `PropertyManagementTab`
- Admin panel tab for managing properties
- Features:
  - List all properties
  - Search properties
  - Deactivate/activate properties
  - Reset property passwords
  - View property details

### 5. Services

#### `InvisionSetupService`
- Manages the single Invision admin account
- Prevents multiple admin accounts
- Uses system config to track admin creation

#### `AuthService` Updates
- Added `createPropertyAccount()` - Creates property accounts
- Added `getAllProperties()` - Gets all property accounts
- Added `searchProperties()` - Searches properties by name
- Added `hasInvisionAdmin()` - Checks if admin exists
- Removed organization-based methods

#### `AuthProvider` Updates
- Added `isInvisionAdmin` - Check if user is Invision admin
- Added `isProperty` - Check if user is property
- Added `canManageProperties()` - Permission check
- Added `canViewStatistics()` - Permission check
- Added `createPropertyAccount()` - Create property wrapper

### 6. Routing Changes

**New Routes:**
- `/invision-setup` - Initial admin setup
- `/admin-dashboard` - Invision admin dashboard
- `/property-dashboard` - Property dashboard

**Route Logic:**
1. On app start, check if Invision admin exists
2. If no admin, redirect to `/invision-setup`
3. After login, route based on user role:
   - `invisionAdmin` → `/admin-dashboard`
   - `property` → `/property-dashboard`

### 7. Security Measures

1. **Single Admin Enforcement:**
   - System config document tracks admin creation
   - Prevents multiple admin accounts
   - Admin creation only through setup screen

2. **Property Isolation:**
   - Properties can only see their own referrals
   - No access to statistics or analytics
   - Separate dashboard with limited features

3. **Admin-Only Actions:**
   - Only admin can create property accounts
   - Only admin can view all referrals
   - Only admin can access analytics

### 8. Database Structure

#### Users Collection
```javascript
{
  id: string,
  email: string,
  firstName: string,
  lastName: string,
  role: "invisionAdmin" | "property",
  propertyName: string?,  // For property accounts
  propertyAddress: string?,  // For property accounts
  phone: string?,
  address: string?,
  isActive: boolean,
  createdAt: timestamp,
  lastLoginAt: timestamp?
}
```

#### System Config Collection
```javascript
{
  invision: {
    adminCreated: boolean,
    adminId: string,
    createdAt: timestamp
  }
}
```

### 9. Firestore Security Rules (To Be Updated)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // System config - read only
    match /system_config/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only through admin SDK
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read their own data
      allow read: if request.auth.uid == userId;
      
      // Only Invision admin can read all users
      allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'invisionAdmin';
      
      // Only Invision admin can create users
      allow create: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'invisionAdmin';
      
      // Users can update their own profile (limited fields)
      allow update: if request.auth.uid == userId 
        && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role', 'isActive']);
      
      // Only admin can update role and isActive
      allow update: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'invisionAdmin';
    }
    
    // Referrals collection
    match /referrals/{referralId} {
      // Properties can read their own referrals
      allow read: if resource.data.submittedBy == request.auth.uid;
      
      // Invision admin can read all referrals
      allow read: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'invisionAdmin';
      
      // Properties can create referrals
      allow create: if request.auth != null 
        && request.resource.data.submittedBy == request.auth.uid;
      
      // Only admin can update referrals
      allow update: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'invisionAdmin';
    }
  }
}
```

### 10. Migration Steps

1. **Create Invision Admin:**
   - Run app for first time
   - Complete Invision setup screen
   - Creates single admin account

2. **Create Property Accounts:**
   - Login as Invision admin
   - Go to Admin Panel → Properties tab
   - Click "Add Property"
   - Fill in property details
   - Property receives login credentials

3. **Property Usage:**
   - Property logs in with credentials
   - Sees simplified dashboard
   - Can submit referrals
   - Can view their own referrals only

### 11. Testing Checklist

- [ ] Invision admin setup works
- [ ] Only one admin can be created
- [ ] Admin can create property accounts
- [ ] Property accounts can login
- [ ] Properties see simplified dashboard
- [ ] Properties cannot see statistics
- [ ] Properties can submit referrals
- [ ] Properties can only see their own referrals
- [ ] Admin can see all referrals
- [ ] Admin can view analytics
- [ ] Admin can deactivate properties
- [ ] Deactivated properties cannot login
- [ ] Password reset works for properties

### 12. Future Enhancements

- Email notifications for new referrals
- Property-specific referral codes
- Referral status tracking
- Commission tracking per property
- Bulk property import
- Property performance reports (admin only)
- API for property integrations

## Summary

The restructure successfully transforms FireReferral from a multi-organization system to a focused single-admin platform where:

1. **Invision** is the sole administrator with full access
2. **Properties** can only submit referrals and view their own data
3. **Security** is enforced through role-based access control
4. **Simplicity** is achieved through a flat structure
5. **Privacy** is maintained by isolating property data

This structure ensures that property accounts have no access to statistics, analytics, or any insider information, while giving Invision complete control and visibility over the entire referral system.
