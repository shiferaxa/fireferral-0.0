# Firebase Security Rules Documentation

## Overview

This document explains the comprehensive security rules implemented for the Fireferral app, covering both Firestore database and Firebase Storage.

## 🔐 **Security Principles**

### **1. Role-Based Access Control (RBAC)**
- **Admin**: Full access within their organization
- **Associate**: Can manage assigned affiliates and their referrals
- **Affiliate**: Can manage their own referrals and profile

### **2. Organization Isolation**
- Users can only access data within their organization
- Complete tenant isolation for multi-organization support
- No cross-organization data leakage

### **3. Data Integrity**
- Critical fields cannot be modified by regular users
- Audit trail preservation (no deletion of referrals/logs)
- Status-based permissions (active users only)

### **4. Principle of Least Privilege**
- Users get minimum permissions needed for their role
- Explicit deny for undefined access patterns
- Read/write permissions separated where appropriate

---

## 📊 **Firestore Security Rules**

### **Helper Functions**
```javascript
isAuthenticated()     // User is logged in
getUserData()         // Get current user's data
isAdmin()            // User has admin role
isAssociate()        // User has associate role  
isAffiliate()        // User has affiliate role
isOwner(userId)      // User owns the resource
isSameOrganization() // Same organization check
isActiveUser()       // User account is active
```

### **Collection Rules**

#### **👥 Users Collection**
- **Read**: Own profile + admin can read org users + associates can read their affiliates
- **Update**: Own profile (limited fields) + admin can update org users
- **Create**: Admin can create users in their organization
- **Delete**: Disabled (use `isActive` flag)

**Protected Fields**: `role`, `organizationId`, `isActive`, `associateId`

#### **🏢 Organizations Collection**
- **Read**: Users can read their own organization
- **Update**: Only admins can update organization settings
- **Create**: Allowed for initial setup
- **Delete**: Disabled

#### **🎯 Referrals Collection**
- **Read**: Own referrals + associates read affiliate referrals + admin reads all org referrals
- **Create**: Users can create referrals in their organization
- **Update**: 
  - Users: Own pending referrals (limited fields)
  - Associates: Status updates for affiliate referrals
  - Admins: All referrals in organization
- **Delete**: Disabled (audit trail)

**Protected Fields**: `submittedBy`, `organizationId`, `commissionAmount`

#### **📦 Packages Collection**
- **Read**: All authenticated active users
- **Write**: Only admins in their organization

#### **💰 Commission Settings**
- **Read**: All users in organization
- **Write**: Only admins in their organization

#### **📈 Analytics Collection**
- **Read**: 
  - Admins: All org analytics
  - Associates/Affiliates: Own performance data
- **Write**: System only (Cloud Functions)

#### **📋 Audit Logs**
- **Read**: Only admins in organization
- **Write**: System only

#### **🔔 Notifications**
- **Read**: Own notifications only
- **Update**: Mark as read only
- **Delete**: Own notifications only

---

## 📁 **Firebase Storage Rules**

### **File Type Restrictions**
- **Images**: `image/*` types, 5MB limit
- **Documents**: PDF, Word, text files, 10MB limit

### **Storage Structure**

#### **👤 User Profile Pictures**
`/users/{userId}/profile/{fileName}`
- **Upload**: Own profile only, image files
- **Read**: Own profile + admins in org

#### **🏢 Organization Branding**
`/organizations/{orgId}/branding/{fileName}`
- **Upload**: Admins only, image files
- **Read**: All users in organization

#### **📄 Referral Documents**
`/referrals/{referralId}/documents/{fileName}`
- **Upload**: Referral owner only, document files
- **Read**: Referral owner + associates (for their affiliates) + admins

#### **📊 System Exports**
`/exports/{orgId}/{fileName}`
- **Upload/Read**: Admins only in organization

#### **⏳ Temporary Uploads**
`/temp/{userId}/{fileName}`
- **Upload/Read**: Own temp folder only
- **Auto-cleanup**: 24 hours (via Cloud Functions)

---

## 🚀 **Deployment Instructions**

### **1. Deploy Firestore Rules**
```bash
firebase deploy --only firestore:rules
```

### **2. Deploy Storage Rules**
```bash
firebase deploy --only storage
```

### **3. Deploy Both**
```bash
firebase deploy --only firestore:rules,storage
```

### **4. Test Rules**
```bash
firebase emulators:start --only firestore,storage
```

---

## 🧪 **Testing Security Rules**

### **Test Scenarios**

#### **✅ Should Allow**
- Admin reading all users in their organization
- User updating their own profile (non-protected fields)
- Associate reading referrals from their affiliates
- User uploading their own profile picture

#### **❌ Should Deny**
- User accessing data from different organization
- Affiliate trying to read admin-only analytics
- User modifying their own role or organizationId
- Unauthorized file uploads to system folders

### **Test Commands**
```bash
# Start emulator
firebase emulators:start --only firestore,storage

# Run security rule tests
npm test -- --testPathPattern=security-rules
```

---

## 🔧 **Maintenance**

### **Regular Tasks**
1. **Review Access Logs**: Monitor for unauthorized access attempts
2. **Update Rules**: When adding new features or collections
3. **Performance Monitoring**: Check rule evaluation performance
4. **Security Audits**: Regular security reviews

### **Rule Updates**
When modifying rules:
1. Test in emulator first
2. Deploy to staging environment
3. Run comprehensive tests
4. Deploy to production
5. Monitor for issues

---

## 🚨 **Security Considerations**

### **Current Protections**
- ✅ **Authentication Required**: All access requires valid Firebase Auth
- ✅ **Role-Based Access**: Proper RBAC implementation
- ✅ **Organization Isolation**: Complete tenant separation
- ✅ **Data Integrity**: Protected critical fields
- ✅ **File Upload Security**: Type and size restrictions
- ✅ **Audit Trail**: No deletion of critical records

### **Additional Recommendations**
- **Rate Limiting**: Implement at application level
- **Input Validation**: Validate data before Firestore writes
- **Monitoring**: Set up alerts for suspicious activity
- **Backup Strategy**: Regular automated backups
- **Disaster Recovery**: Test restore procedures

---

## 📞 **Support**

For security rule questions or issues:
1. Check this documentation first
2. Test in Firebase emulator
3. Review Firebase console logs
4. Contact development team

**Remember**: Security rules are your last line of defense. Always validate data at the application level too!