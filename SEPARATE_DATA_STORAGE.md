# Separate Data Storage for NGO Members and Users

## 📋 Overview

This implementation creates separate Firestore collections to handle different types of users in the Connect & Contribute app:

- **Regular Users** (volunteers, donors) → `users` collection
- **NGO Members** (staff, coordinators, admins) → `ngo_members` collection  
- **NGO Organizations** → `ngos` collection

## 🗄️ Database Structure

### 1. Users Collection (`users`)
**Purpose**: Store individual volunteers and donors

**Key Fields**:
```dart
{
  uid: String,                    // Firebase Auth UID
  name: String,                   // Full name
  email: String,                  // Email address
  phone: String,                  // Phone number
  userType: String,               // 'volunteer' or 'donor'
  address: String,                // Physical address
  interests: List<String>,        // Causes they care about
  totalDonated: double,           // Total donations made
  volunteerHours: int,            // Hours volunteered
  completedTasks: int,            // Tasks completed
  rating: double,                 // User rating (0-5)
  skills: List<String>,           // Skills and abilities
  occupation: String,             // Job/profession
  dateOfBirth: DateTime?,         // Birth date
  emergencyContact: String,       // Emergency contact info
  preferences: Map<String, dynamic>, // User preferences
  createdAt: DateTime,            // Account creation date
  lastLogin: DateTime?,           // Last login time
  isActive: bool,                 // Account status
  profileImageUrl: String,        // Profile picture URL
}
```

### 2. NGO Members Collection (`ngo_members`)
**Purpose**: Store NGO staff and team members

**Key Fields**:
```dart
{
  uid: String,                    // Firebase Auth UID
  name: String,                   // Full name
  email: String,                  // Email address
  phone: String,                  // Phone number
  ngoId: String,                  // Reference to NGO they belong to
  position: String,               // 'admin', 'coordinator', 'member', etc.
  permissions: List<String>,      // What they can do ['view', 'create', 'edit', 'delete']
  department: String,             // Which department they work in
  joinedAt: DateTime?,            // When they joined the NGO
  isAdmin: bool,                  // Admin privileges
  salary: double,                 // Salary (if applicable)
  employeeId: String,             // Employee ID number
  responsibilities: List<String>, // Job responsibilities
  workSchedule: String,           // Work schedule
  emergencyContact: String,       // Emergency contact
  additionalInfo: Map<String, dynamic>, // Extra info
  createdAt: DateTime,            // Account creation date
  lastLogin: DateTime?,           // Last login time
  isActive: bool,                 // Account status
  profileImageUrl: String,        // Profile picture URL
}
```

### 3. NGOs Collection (`ngos`)
**Purpose**: Store NGO organization information

**Key Fields**:
```dart
{
  uid: String,                    // NGO unique ID
  name: String,                   // NGO name
  description: String,            // NGO description
  contactEmail: String,           // Primary contact email
  contactPhone: String,           // Primary contact phone
  address: String,                // NGO address
  registrationNumber: String,     // Legal registration number
  category: String,               // 'education', 'health', 'environment', etc.
  causes: List<String>,           // Causes they support
  isVerified: bool,               // Verification status
  createdAt: DateTime,            // Registration date
  updatedAt: DateTime,            // Last update
  logoUrl: String,                // NGO logo URL
  websiteUrl: String,             // Website URL
  socialMedia: Map<String, String>, // Social media links
  totalDonationsReceived: double, // Total donations received
  totalVolunteers: int,           // Total volunteers
  totalMembers: int,              // Total staff members
  rating: double,                 // NGO rating (0-5)
  certifications: List<String>,   // Certifications
  foundedYear: String,            // Year founded
  legalStatus: String,            // Legal status
  serviceAreas: List<String>,     // Areas they serve
  bankDetails: Map<String, dynamic>, // Banking information
  isActive: bool,                 // NGO status
}
```

## 🔄 Registration Flow

### For Regular Users (Individual/Volunteer/Donor):
1. User selects "Individual" user type
2. Fills out basic information (name, email, phone, password)
3. Completes phone verification
4. Account created in `users` collection
5. Stats document created in `userStats` collection

### For NGO Members:
1. User selects "NGO" user type
2. Selects which NGO to join from dropdown
3. Selects their position (member, coordinator, admin)
4. Fills out basic information
5. Completes phone verification
6. Account created in `ngo_members` collection
7. Stats document created in `ngoMemberStats` collection
8. NGO's `totalMembers` count incremented

## 🎯 Benefits of Separate Collections

### 1. **Clear Data Separation**
- Regular users and NGO members have different data requirements
- No confusion between user types
- Easier to manage permissions and access control

### 2. **Optimized Queries**
- Faster queries when filtering by user type
- Better indexing strategies
- Reduced data transfer

### 3. **Scalability**
- Each collection can be optimized independently
- Different security rules for each collection
- Easier to add type-specific fields

### 4. **Role-Based Access**
- NGO members can have specific permissions within their NGO
- Users have different capabilities than NGO members
- Clear hierarchy and access control

## 🛠️ Implementation Files

### Models (`lib/models/app_models.dart`)
- `BaseUser` - Abstract base class for common fields
- `UserModel` - Regular users (volunteers, donors)
- `NGOMemberModel` - NGO staff and members
- `NGOModel` - NGO organizations

### Services (`lib/services/firestore_service.dart`)
- `createUser()` - Create regular user
- `createNGOMember()` - Create NGO member
- `createNGO()` - Create NGO organization
- `getUserById()` - Get user by ID
- `getNGOMemberById()` - Get NGO member by ID
- `getNGOMembers(ngoId)` - Get all members of an NGO
- `updateUser()` - Update user profile
- `updateNGOMember()` - Update NGO member profile
- `removeNGOMember()` - Remove NGO member (soft delete)

### Authentication (`lib/services/optimized_auth_service.dart`)
- Enhanced `registerWithEmailPasswordOTP()` method
- Supports both user types with optional NGO parameters
- Creates appropriate documents based on user type
- Handles batch operations for efficiency

### UI (`lib/screens/signup_flow_screen.dart`)
- User type selection (Individual vs NGO)
- NGO selection dropdown (for NGO members)
- Position selection dropdown (for NGO members)
- Validation for NGO member requirements

## 🚀 Usage Examples

### Creating a Regular User:
```dart
final user = UserModel(
  uid: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  userType: 'volunteer',
  interests: ['education', 'environment'],
  skills: ['teaching', 'organizing'],
);

await firestoreService.createUser(user);
```

### Creating an NGO Member:
```dart
final member = NGOMemberModel(
  uid: 'member123',
  name: 'Jane Smith',
  email: 'jane@ngo.org',
  phone: '+1987654321',
  ngoId: 'ngo456',
  position: 'coordinator',
  permissions: ['view', 'create', 'edit'],
  department: 'Community Outreach',
);

await firestoreService.createNGOMember(member);
```

### Querying Data:
```dart
// Get all volunteers
final volunteers = await firestoreService.getUsersByType('volunteer');

// Get all members of a specific NGO
final ngoMembers = await firestoreService.getNGOMembers('ngo456');

// Get NGO admins
final admins = await firestoreService.getNGOMembersByPosition('ngo456', 'admin');
```

## 🔒 Security Considerations

### Firestore Rules Example:
```javascript
// Users collection - users can only read/write their own data
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

// NGO Members collection - members can read other members of same NGO
match /ngo_members/{memberId} {
  allow read: if request.auth != null && 
    (request.auth.uid == memberId || 
     get(/databases/$(database)/documents/ngo_members/$(request.auth.uid)).data.ngoId == 
     get(/databases/$(database)/documents/ngo_members/$(memberId)).data.ngoId);
  allow write: if request.auth != null && request.auth.uid == memberId;
}

// NGOs collection - verified NGOs are publicly readable
match /ngos/{ngoId} {
  allow read: if resource.data.isVerified == true;
  allow write: if request.auth != null && 
    exists(/databases/$(database)/documents/ngo_members/$(request.auth.uid)) &&
    get(/databases/$(database)/documents/ngo_members/$(request.auth.uid)).data.ngoId == ngoId &&
    get(/databases/$(database)/documents/ngo_members/$(request.auth.uid)).data.isAdmin == true;
}
```

## 📈 Performance Benefits

1. **Targeted Queries**: Query only the collection you need
2. **Efficient Indexing**: Each collection can have optimized indexes
3. **Reduced Payload**: Smaller documents with relevant fields only
4. **Parallel Processing**: Different operations can run on different collections
5. **Caching Strategy**: Different caching policies for different data types

## 🔧 Migration Strategy

If migrating from a single collection:

1. **Phase 1**: Create new collections alongside existing one
2. **Phase 2**: Write to both old and new collections
3. **Phase 3**: Migrate existing data using batch operations
4. **Phase 4**: Switch reads to new collections
5. **Phase 5**: Remove old collection and migration code

This structure provides a solid foundation for managing different types of users while maintaining data integrity and performance.
