import 'package:cloud_firestore/cloud_firestore.dart';

// Base user class for common fields
abstract class BaseUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String profileImageUrl;

  BaseUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.profileImageUrl = '',
  });
}

// Regular User Model (Individual users - volunteers, donors)
class UserModel extends BaseUser {
  final String userType; // volunteer, donor
  final String address;
  final List<String> interests; // causes they're interested in
  final double totalDonated;
  final int volunteerHours;
  final int completedTasks;
  final double rating;
  final List<String> skills;
  final String occupation;
  final DateTime? dateOfBirth;
  final String emergencyContact;
  final Map<String, dynamic> preferences;

  UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    super.createdAt,
    super.lastLogin,
    super.isActive = true,
    super.profileImageUrl = '',
    required this.userType,
    this.address = '',
    this.interests = const [],
    this.totalDonated = 0.0,
    this.volunteerHours = 0,
    this.completedTasks = 0,
    this.rating = 0.0,
    this.skills = const [],
    this.occupation = '',
    this.dateOfBirth,
    this.emergencyContact = '',
    this.preferences = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      userType: data['userType'] ?? 'volunteer',
      address: data['address'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      totalDonated: (data['totalDonated'] ?? 0).toDouble(),
      volunteerHours: data['volunteerHours'] ?? 0,
      completedTasks: data['completedTasks'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      skills: List<String>.from(data['skills'] ?? []),
      occupation: data['occupation'] ?? '',
      dateOfBirth: data['dateOfBirth']?.toDate(),
      emergencyContact: data['emergencyContact'] ?? '',
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      userType: data['userType'] ?? 'volunteer',
      address: data['address'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      totalDonated: (data['totalDonated'] ?? 0).toDouble(),
      volunteerHours: data['volunteerHours'] ?? 0,
      completedTasks: data['completedTasks'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      skills: List<String>.from(data['skills'] ?? []),
      occupation: data['occupation'] ?? '',
      dateOfBirth: data['dateOfBirth']?.toDate(),
      emergencyContact: data['emergencyContact'] ?? '',
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType,
      'address': address,
      'interests': interests,
      'totalDonated': totalDonated,
      'volunteerHours': volunteerHours,
      'completedTasks': completedTasks,
      'rating': rating,
      'skills': skills,
      'occupation': occupation,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'emergencyContact': emergencyContact,
      'preferences': preferences,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }
}

// NGO Member Model (Individual members working for NGOs)
class NGOMemberModel extends BaseUser {
  final String ngoId; // Reference to the NGO they belong to
  final String position; // admin, coordinator, volunteer, etc.
  final List<String> permissions; // what they can do in the NGO
  final String department; // which department they work in
  final DateTime? joinedAt;
  final bool isAdmin;
  final double salary;
  final String employeeId;
  final List<String> responsibilities;
  final String workSchedule;
  final String emergencyContact;
  final Map<String, dynamic> additionalInfo;
  // New fields for admin system
  final String? ngoName; // Name of NGO entered by user
  final String? ngoCode; // NGO code entered by user
  final bool isVerified; // Whether admin has verified this member
  // New approval fields
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final DateTime? appliedAt; // When user applied
  final String? rejectionReason; // Reason for rejection

  NGOMemberModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    super.createdAt,
    super.lastLogin,
    super.isActive = true,
    super.profileImageUrl = '',
    required this.ngoId,
    required this.position,
    this.permissions = const [],
    this.department = '',
    this.joinedAt,
    this.isAdmin = false,
    this.salary = 0.0,
    this.employeeId = '',
    this.responsibilities = const [],
    this.workSchedule = '',
    this.emergencyContact = '',
    this.additionalInfo = const {},
    this.ngoName,
    this.ngoCode,
    this.isVerified = false,
    this.approvalStatus = 'pending',
    this.appliedAt,
    this.rejectionReason,
  });

  factory NGOMemberModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NGOMemberModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      ngoId: data['ngoId'] ?? '',
      position: data['position'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      department: data['department'] ?? '',
      joinedAt: data['joinedAt']?.toDate(),
      isAdmin: data['isAdmin'] ?? false,
      salary: (data['salary'] ?? 0).toDouble(),
      employeeId: data['employeeId'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      workSchedule: data['workSchedule'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
      ngoName: data['ngoName'],
      ngoCode: data['ngoCode'],
      isVerified: data['isVerified'] ?? false,
      approvalStatus: data['approvalStatus'] ?? 'pending',
      appliedAt: data['appliedAt']?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  factory NGOMemberModel.fromMap(Map<String, dynamic> data) {
    return NGOMemberModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      ngoId: data['ngoId'] ?? '',
      position: data['position'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      department: data['department'] ?? '',
      joinedAt: data['joinedAt']?.toDate(),
      isAdmin: data['isAdmin'] ?? false,
      salary: (data['salary'] ?? 0).toDouble(),
      employeeId: data['employeeId'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      workSchedule: data['workSchedule'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
      ngoName: data['ngoName'],
      ngoCode: data['ngoCode'],
      isVerified: data['isVerified'] ?? false,
      approvalStatus: data['approvalStatus'] ?? 'pending',
      appliedAt: data['appliedAt']?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'ngoId': ngoId,
      'position': position,
      'permissions': permissions,
      'department': department,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : null,
      'isAdmin': isAdmin,
      'salary': salary,
      'employeeId': employeeId,
      'responsibilities': responsibilities,
      'workSchedule': workSchedule,
      'emergencyContact': emergencyContact,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'ngoName': ngoName,
      'ngoCode': ngoCode,
      'isVerified': isVerified,
      'approvalStatus': approvalStatus,
      'appliedAt': appliedAt != null ? Timestamp.fromDate(appliedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }
}

class NGOModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final String contactEmail;
  final String contactPhone;
  final String website;
  final int establishedYear;
  final String registrationNumber;
  final bool isVerified;
  final bool isActive;
  final int memberCount;
  final List<String> activities;
  final Map<String, String> socialMediaLinks;
  final Map<String, dynamic> additionalInfo;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String ngoCode; // Unique code for NGO identification

  NGOModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.contactEmail,
    required this.contactPhone,
    required this.website,
    required this.establishedYear,
    required this.registrationNumber,
    required this.isVerified,
    required this.isActive,
    required this.memberCount,
    required this.activities,
    required this.socialMediaLinks,
    required this.additionalInfo,
    required this.createdAt,
    required this.lastUpdated,
    required this.ngoCode,
  });

  factory NGOModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return NGOModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      website: data['website'] ?? '',
      establishedYear: data['establishedYear'] ?? DateTime.now().year,
      registrationNumber: data['registrationNumber'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      memberCount: data['memberCount'] ?? 0,
      activities: List<String>.from(data['activities'] ?? []),
      socialMediaLinks: Map<String, String>.from(data['socialMediaLinks'] ?? {}),
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
      ngoCode: data['ngoCode'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'establishedYear': establishedYear,
      'registrationNumber': registrationNumber,
      'isVerified': isVerified,
      'isActive': isActive,
      'memberCount': memberCount,
      'activities': activities,
      'socialMediaLinks': socialMediaLinks,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'ngoCode': ngoCode,
    };
  }

  NGOModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? location,
    String? contactEmail,
    String? contactPhone,
    String? website,
    int? establishedYear,
    String? registrationNumber,
    bool? isVerified,
    bool? isActive,
    int? memberCount,
    List<String>? activities,
    Map<String, String>? socialMediaLinks,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? ngoCode,
  }) {
    return NGOModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      establishedYear: establishedYear ?? this.establishedYear,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      memberCount: memberCount ?? this.memberCount,
      activities: activities ?? this.activities,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      ngoCode: ngoCode ?? this.ngoCode,
    );
  }
}

class DonationRequestModel {
  final String id;
  final String ngoId;
  final String title;
  final String description;
  final String category;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String urgencyLevel;
  final List<String> itemsNeeded;
  final List<String> itemsReceived;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final int donorCount;
  final List<String> imageUrls;

  DonationRequestModel({
    required this.id,
    required this.ngoId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.deadline,
    required this.urgencyLevel,
    required this.itemsNeeded,
    this.itemsReceived = const [],
    required this.createdBy,
    this.createdAt,
    this.status = 'active',
    this.donorCount = 0,
    this.imageUrls = const [],
  });

  factory DonationRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return DonationRequestModel(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      deadline: data['deadline']?.toDate() ?? DateTime.now(),
      urgencyLevel: data['urgencyLevel'] ?? 'medium',
      itemsNeeded: List<String>.from(data['itemsNeeded'] ?? []),
      itemsReceived: List<String>.from(data['itemsReceived'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      status: data['status'] ?? 'active',
      donorCount: data['donorCount'] ?? 0,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isUrgent => urgencyLevel == 'high' || urgencyLevel == 'critical';
  
  int get daysLeft {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }
}

class VolunteerOpportunityModel {
  final String id;
  final String ngoId;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> skillsRequired;
  final int volunteersNeeded;
  final int volunteersRegistered;
  final String timeCommitment;
  final String createdBy;
  final DateTime? createdAt;
  final String status;
  final List<String> registeredVolunteers;
  final List<String> imageUrls;

  VolunteerOpportunityModel({
    required this.id,
    required this.ngoId,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.skillsRequired,
    required this.volunteersNeeded,
    this.volunteersRegistered = 0,
    required this.timeCommitment,
    required this.createdBy,
    this.createdAt,
    this.status = 'active',
    this.registeredVolunteers = const [],
    this.imageUrls = const [],
  });

  factory VolunteerOpportunityModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return VolunteerOpportunityModel(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      startDate: data['startDate']?.toDate() ?? DateTime.now(),
      endDate: data['endDate']?.toDate() ?? DateTime.now(),
      skillsRequired: List<String>.from(data['skillsRequired'] ?? []),
      volunteersNeeded: data['volunteersNeeded'] ?? 0,
      volunteersRegistered: data['volunteersRegistered'] ?? 0,
      timeCommitment: data['timeCommitment'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      status: data['status'] ?? 'active',
      registeredVolunteers: List<String>.from(data['registeredVolunteers'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  bool get isFull => volunteersRegistered >= volunteersNeeded;
  
  double get fillPercentage {
    if (volunteersNeeded <= 0) return 0;
    return (volunteersRegistered / volunteersNeeded).clamp(0.0, 1.0);
  }
  
  int get daysUntilStart {
    final now = DateTime.now();
    final difference = startDate.difference(now);
    return difference.inDays;
  }
}

// Admin Model (System administrators)
class AdminModel extends BaseUser {
  final String role; // super_admin, admin, moderator
  final List<String> permissions; // what they can do in the system
  final String department; // which department they belong to
  final DateTime? lastAdminAction;
  final Map<String, dynamic> adminSettings;
  final List<String> managedNGOs; // NGO IDs they can manage
  final bool canCreateNGOs;
  final bool canDeleteNGOs;
  final bool canVerifyMembers;
  final bool canAccessAnalytics;
  final Map<String, dynamic> additionalPrivileges;

  AdminModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    super.createdAt,
    super.lastLogin,
    super.isActive = true,
    super.profileImageUrl = '',
    this.role = 'admin',
    this.permissions = const [],
    this.department = 'General',
    this.lastAdminAction,
    this.adminSettings = const {},
    this.managedNGOs = const [],
    this.canCreateNGOs = true,
    this.canDeleteNGOs = true,
    this.canVerifyMembers = true,
    this.canAccessAnalytics = true,
    this.additionalPrivileges = const {},
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AdminModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      department: data['department'] ?? 'General',
      lastAdminAction: data['lastAdminAction']?.toDate(),
      adminSettings: Map<String, dynamic>.from(data['adminSettings'] ?? {}),
      managedNGOs: List<String>.from(data['managedNGOs'] ?? []),
      canCreateNGOs: data['canCreateNGOs'] ?? true,
      canDeleteNGOs: data['canDeleteNGOs'] ?? true,
      canVerifyMembers: data['canVerifyMembers'] ?? true,
      canAccessAnalytics: data['canAccessAnalytics'] ?? true,
      additionalPrivileges: Map<String, dynamic>.from(data['additionalPrivileges'] ?? {}),
    );
  }

  factory AdminModel.fromMap(Map<String, dynamic> data) {
    return AdminModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      profileImageUrl: data['profileImageUrl'] ?? '',
      role: data['role'] ?? 'admin',
      permissions: List<String>.from(data['permissions'] ?? []),
      department: data['department'] ?? 'General',
      lastAdminAction: data['lastAdminAction']?.toDate(),
      adminSettings: Map<String, dynamic>.from(data['adminSettings'] ?? {}),
      managedNGOs: List<String>.from(data['managedNGOs'] ?? []),
      canCreateNGOs: data['canCreateNGOs'] ?? true,
      canDeleteNGOs: data['canDeleteNGOs'] ?? true,
      canVerifyMembers: data['canVerifyMembers'] ?? true,
      canAccessAnalytics: data['canAccessAnalytics'] ?? true,
      additionalPrivileges: Map<String, dynamic>.from(data['additionalPrivileges'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'permissions': permissions,
      'department': department,
      'lastAdminAction': lastAdminAction,
      'adminSettings': adminSettings,
      'managedNGOs': managedNGOs,
      'canCreateNGOs': canCreateNGOs,
      'canDeleteNGOs': canDeleteNGOs,
      'canVerifyMembers': canVerifyMembers,
      'canAccessAnalytics': canAccessAnalytics,
      'additionalPrivileges': additionalPrivileges,
    };
  }
}
