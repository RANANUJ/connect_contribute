# 🗃️ Firestore Database Structure - Three Collections

## 📋 Overview

The Connect & Contribute app now uses a well-organized three-collection structure in Firestore to separate different types of users and their data:

## 🗂️ Collection Structure

### 1. 📱 **`users` Collection** - Regular Users
**Purpose**: Individual volunteers, donors, and regular users

**Document Structure**:
```javascript
{
  uid: "user_unique_id",
  name: "John Doe",
  email: "john@example.com",
  phone: "+91-9999999999",
  userType: "volunteer", // volunteer, donor
  address: "123 Main St",
  interests: ["education", "healthcare"],
  totalDonated: 5000.0,
  volunteerHours: 120,
  completedTasks: 15,
  rating: 4.5,
  skills: ["teaching", "fundraising"],
  occupation: "Software Engineer",
  dateOfBirth: Date,
  emergencyContact: "+91-8888888888",
  preferences: {
    notifications: true,
    emailUpdates: false
  },
  emailVerified: true,
  phoneVerified: true,
  createdAt: Timestamp,
  lastLogin: Timestamp,
  isActive: true,
  profileImageUrl: "https://..."
}
```

### 2. 🏢 **`ngo_members` Collection** - NGO Members
**Purpose**: People working with NGOs (staff, volunteers, coordinators)

**Document Structure**:
```javascript
{
  uid: "member_unique_id",
  name: "Jane Smith",
  email: "jane@ngo.org",
  phone: "+91-7777777777",
  ngoId: "ngo_123", // Reference to NGO document
  ngoName: "Green Earth Foundation", // NGO name entered by user
  ngoCode: "GEF123", // NGO code for verification
  position: "coordinator", // admin, coordinator, volunteer, etc.
  permissions: ["create", "edit", "view"],
  department: "Environment",
  joinedAt: Timestamp,
  isAdmin: false,
  salary: 25000.0,
  employeeId: "EMP001",
  responsibilities: ["event_management", "volunteer_coordination"],
  workSchedule: "9 AM - 5 PM",
  emergencyContact: "+91-6666666666",
  additionalInfo: {
    specializations: ["wildlife_conservation"],
    certifications: ["First Aid"]
  },
  emailVerified: true,
  phoneVerified: true,
  createdAt: Timestamp,
  lastLogin: Timestamp,
  isActive: true,
  profileImageUrl: "https://...",
  isVerified: false // Admin verification status
}
```

### 3. 👑 **`admins` Collection** - System Administrators
**Purpose**: System administrators with elevated privileges

**Document Structure**:
```javascript
{
  uid: "admin_001",
  name: "System Administrator",
  email: "rana1452005@gmail.com",
  phone: "+91-9999999999",
  role: "super_admin", // super_admin, admin, moderator
  permissions: [
    "create_ngos",
    "delete_ngos", 
    "verify_members",
    "manage_admins",
    "access_analytics",
    "system_settings"
  ],
  department: "System Administration",
  lastAdminAction: Timestamp,
  adminSettings: {
    theme: "default",
    language: "en",
    notifications: true,
    dashboard_layout: "default"
  },
  managedNGOs: [], // NGO IDs they can manage (empty = all)
  canCreateNGOs: true,
  canDeleteNGOs: true,
  canVerifyMembers: true,
  canAccessAnalytics: true,
  additionalPrivileges: {
    can_create_admins: true,
    can_modify_system_settings: true,
    can_access_all_data: true,
    can_export_data: true
  },
  createdAt: Timestamp,
  lastLogin: Timestamp,
  isActive: true,
  profileImageUrl: "https://..."
}
```

## 🔄 **How It Works**

### **Signup Process**:
1. **Individual Users** → Stored in `users` collection
2. **NGO Members** → Stored in `ngo_members` collection
3. **Admins** → Created via admin panel, stored in `admins` collection

### **Login Process**:
1. **Check admin credentials first** (email: rana1452005@gmail.com)
2. **If admin** → Authenticate against `admins` collection → Admin Dashboard
3. **If regular user** → Firebase Auth → Check `users` or `ngo_members` collection → Home

### **Data Access**:
- **Users**: Can access their own data in `users` collection
- **NGO Members**: Can access their own data in `ngo_members` collection + related NGO data
- **Admins**: Can access all collections based on permissions

## 🎯 **Benefits of This Structure**

### ✅ **Clear Separation**:
- Different user types don't interfere with each other
- Easier to manage permissions and access controls
- Better query performance

### ✅ **Scalability**:
- Each collection can be optimized for its specific use case
- Independent scaling and indexing strategies
- Reduced cross-collection queries

### ✅ **Security**:
- Granular Firestore security rules for each collection
- Role-based access control
- Admin actions are tracked separately

### ✅ **Maintenance**:
- Easier to backup and maintain specific user types
- Cleaner admin dashboard with targeted queries
- Better analytics and reporting

## 📊 **Collection Statistics**

The admin dashboard now shows counts for all three collections:
- **Total Users**: Individual volunteers and donors
- **Total NGO Members**: People working with NGOs
- **Total Admins**: System administrators
- **Total NGOs**: Registered organizations

## 🔐 **Default Admin Account**

**Credentials**:
- **Email**: `rana1452005@gmail.com`
- **Password**: `anuj#123`
- **Role**: `super_admin`
- **UID**: `admin_001`

This account is automatically created during app initialization and has full system privileges.

## 🚀 **Implementation Complete**

The three-collection structure is now fully implemented and working:
- ✅ **Users** stored in `users` collection
- ✅ **NGO Members** stored in `ngo_members` collection  
- ✅ **Admins** stored in `admins` collection
- ✅ **Unified login** with automatic collection detection
- ✅ **Admin panel** with comprehensive data management
- ✅ **Role-based permissions** and access control

Your app now has a professional, scalable database structure ready for production! 🎉
