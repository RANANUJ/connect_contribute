import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER MANAGEMENT (Individual Users) ============
  
  // Create regular user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw 'Failed to create user profile';
    }
  }
  
  // Get all individual users
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get user by ID from users collection
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Error updating user: $e');
      throw 'Failed to update user profile';
    }
  }

  // Get users by type (volunteer, donor)
  Stream<QuerySnapshot> getUsersByType(String userType) {
    return _firestore
        .collection('users')
        .where('userType', isEqualTo: userType)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // ============ NGO MEMBER MANAGEMENT ============
  
  // Create NGO member document
  Future<void> createNGOMember(NGOMemberModel member) async {
    try {
      await _firestore.collection('ngo_members').doc(member.uid).set(member.toMap());
      
      // Update NGO total members count
      await _firestore.collection('ngos').doc(member.ngoId).update({
        'totalMembers': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating NGO member: $e');
      throw 'Failed to create NGO member profile';
    }
  }

  // Get NGO member by ID
  Future<NGOMemberModel?> getNGOMemberById(String memberId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('ngo_members').doc(memberId).get();
      if (doc.exists) {
        return NGOMemberModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting NGO member: $e');
      return null;
    }
  }

  // Get all members of a specific NGO
  Future<List<NGOMemberModel>> getNGOMembers(String ngoId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ngo_members')
          .where('ngoId', isEqualTo: ngoId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return NGOMemberModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting NGO members: $e');
      return [];
    }
  }

  // Get NGO members by NGO ID (Stream version)
  Stream<QuerySnapshot> getNGOMembersByNGOId(String ngoId) {
    return _firestore
        .collection('ngo_members')
        .where('ngoId', isEqualTo: ngoId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Get NGO members by position
  Stream<QuerySnapshot> getNGOMembersByPosition(String ngoId, String position) {
    return _firestore
        .collection('ngo_members')
        .where('ngoId', isEqualTo: ngoId)
        .where('position', isEqualTo: position)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }

  // Update NGO member profile
  Future<void> updateNGOMember(String memberId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('ngo_members').doc(memberId).update(updates);
    } catch (e) {
      print('Error updating NGO member: $e');
      throw 'Failed to update NGO member profile';
    }
  }

  // Remove NGO member (soft delete)
  Future<void> removeNGOMember(String memberId, String ngoId) async {
    try {
      await _firestore.collection('ngo_members').doc(memberId).update({
        'isActive': false,
        'removedAt': FieldValue.serverTimestamp(),
      });
      
      // Update NGO total members count
      await _firestore.collection('ngos').doc(ngoId).update({
        'totalMembers': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error removing NGO member: $e');
      throw 'Failed to remove NGO member';
    }
  }

  // ============ NGO MANAGEMENT ============
  
  // Create NGO profile
  Future<void> createNGO(NGOModel ngo) async {
    try {
      print('Creating NGO with data: ${ngo.toFirestore()}');
      
      // Check if NGO code already exists
      final existingNGO = await getNGOByCode(ngo.ngoCode);
      if (existingNGO != null) {
        throw 'NGO with code ${ngo.ngoCode} already exists';
      }
      
      // Create the NGO document
      final docRef = await _firestore.collection('ngos').add(ngo.toFirestore());
      print('NGO created successfully with ID: ${docRef.id}');
      
    } catch (e) {
      print('Error creating NGO: $e');
      print('NGO data that failed: ${ngo.toFirestore()}');
      if (e.toString().contains('already exists')) {
        throw e.toString();
      } else {
        throw 'Failed to create NGO profile: $e';
      }
    }
  }

  // Get NGO by NGO Code
  Future<NGOModel?> getNGOByCode(String ngoCode) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ngos')
          .where('ngoCode', isEqualTo: ngoCode)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return NGOModel.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting NGO by code: $e');
      return null;
    }
  }

  // Verify NGO credentials (for member signup)
  Future<NGOModel?> verifyNGOCredentials(String ngoName, String ngoCode) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ngos')
          .where('name', isEqualTo: ngoName)
          .where('ngoCode', isEqualTo: ngoCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return NGOModel.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error verifying NGO credentials: $e');
      return null;
    }
  }

  // Get NGO by ID
  Future<NGOModel?> getNGOById(String ngoId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('ngos').doc(ngoId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return NGOModel.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting NGO: $e');
      return null;
    }
  }

  // Update NGO profile
  Future<void> updateNGO(String ngoId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('ngos').doc(ngoId).update(updates);
    } catch (e) {
      print('Error updating NGO: $e');
      throw 'Failed to update NGO profile';
    }
  }

  // Get all NGOs
  Stream<QuerySnapshot> getNGOs() {
    return _firestore
        .collection('ngos')
        .where('isVerified', isEqualTo: true)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots();
  }

  // Get NGOs by category
  Stream<QuerySnapshot> getNGOsByCategory(String category) {
    return _firestore
        .collection('ngos')
        .where('category', isEqualTo: category)
        .where('isVerified', isEqualTo: true)
        .snapshots();
  }

  // ========== Donation Management ==========
  
  // Create donation request
  Future<String> createDonationRequest({
    required String ngoId,
    required String title,
    required String description,
    required String category, // food, clothes, books, money, etc.
    required double targetAmount,
    required DateTime deadline,
    required String urgencyLevel, // low, medium, high, critical
    required List<String> itemsNeeded,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not authenticated';

    DocumentReference docRef = await _firestore.collection('donation_requests').add({
      'ngoId': ngoId,
      'title': title,
      'description': description,
      'category': category,
      'targetAmount': targetAmount,
      'currentAmount': 0.0,
      'deadline': deadline,
      'urgencyLevel': urgencyLevel,
      'itemsNeeded': itemsNeeded,
      'itemsReceived': [],
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active', // active, completed, expired
      'donorCount': 0,
      'imageUrls': [],
    });

    return docRef.id;
  }

  // Get active donation requests
  Stream<QuerySnapshot> getActiveDonationRequests() {
    return _firestore
        .collection('donation_requests')
        .where('status', isEqualTo: 'active')
        .where('deadline', isGreaterThan: DateTime.now())
        .orderBy('deadline')
        .orderBy('urgencyLevel')
        .snapshots();
  }

  // Get donation requests by category
  Stream<QuerySnapshot> getDonationRequestsByCategory(String category) {
    return _firestore
        .collection('donation_requests')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  // ========== Volunteer Management ==========
  
  // Create volunteer opportunity
  Future<String> createVolunteerOpportunity({
    required String ngoId,
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> skillsRequired,
    required int volunteersNeeded,
    required String timeCommitment, // one-time, weekly, monthly
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not authenticated';

    DocumentReference docRef = await _firestore.collection('volunteer_opportunities').add({
      'ngoId': ngoId,
      'title': title,
      'description': description,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'skillsRequired': skillsRequired,
      'volunteersNeeded': volunteersNeeded,
      'volunteersRegistered': 0,
      'timeCommitment': timeCommitment,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active', // active, completed, cancelled
      'registeredVolunteers': [],
      'imageUrls': [],
    });

    return docRef.id;
  }

  // Get active volunteer opportunities
  Stream<QuerySnapshot> getActiveVolunteerOpportunities() {
    return _firestore
        .collection('volunteer_opportunities')
        .where('status', isEqualTo: 'active')
        .where('startDate', isGreaterThan: DateTime.now())
        .orderBy('startDate')
        .snapshots();
  }

  // Register for volunteer opportunity
  Future<void> registerForVolunteerOpportunity(String opportunityId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not authenticated';

    await _firestore.runTransaction((transaction) async {
      DocumentReference opportunityRef = _firestore
          .collection('volunteer_opportunities')
          .doc(opportunityId);
      
      DocumentSnapshot opportunitySnapshot = await transaction.get(opportunityRef);
      
      if (!opportunitySnapshot.exists) {
        throw 'Volunteer opportunity not found';
      }

      List<dynamic> registeredVolunteers = opportunitySnapshot['registeredVolunteers'] ?? [];
      
      if (registeredVolunteers.contains(user.uid)) {
        throw 'Already registered for this opportunity';
      }

      registeredVolunteers.add(user.uid);
      int newCount = (opportunitySnapshot['volunteersRegistered'] ?? 0) + 1;

      transaction.update(opportunityRef, {
        'registeredVolunteers': registeredVolunteers,
        'volunteersRegistered': newCount,
      });

      // Create volunteer registration record
      transaction.set(
        _firestore.collection('volunteer_registrations').doc(),
        {
          'userId': user.uid,
          'opportunityId': opportunityId,
          'registeredAt': FieldValue.serverTimestamp(),
          'status': 'registered', // registered, completed, cancelled
        },
      );
    });
  }

  // ========== Donation Tracking ==========
  
  // Record a donation
  Future<void> recordDonation({
    required String donationRequestId,
    required String donorId,
    required double amount,
    required String type, // money, items
    List<String>? itemsDonated,
    String? notes,
  }) async {
    await _firestore.collection('donations').add({
      'donationRequestId': donationRequestId,
      'donorId': donorId,
      'amount': amount,
      'type': type,
      'itemsDonated': itemsDonated ?? [],
      'notes': notes ?? '',
      'donatedAt': FieldValue.serverTimestamp(),
      'status': 'completed',
    });

    // Update donation request
    await _firestore.runTransaction((transaction) async {
      DocumentReference requestRef = _firestore
          .collection('donation_requests')
          .doc(donationRequestId);
      
      DocumentSnapshot requestSnapshot = await transaction.get(requestRef);
      
      if (requestSnapshot.exists) {
        double currentAmount = (requestSnapshot['currentAmount'] ?? 0.0) + amount;
        int donorCount = (requestSnapshot['donorCount'] ?? 0) + 1;

        transaction.update(requestRef, {
          'currentAmount': currentAmount,
          'donorCount': donorCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Get user's donation history
  Stream<QuerySnapshot> getUserDonations(String userId) {
    return _firestore
        .collection('donations')
        .where('donorId', isEqualTo: userId)
        .orderBy('donatedAt', descending: true)
        .snapshots();
  }

  // Get user's volunteer history
  Stream<QuerySnapshot> getUserVolunteerHistory(String userId) {
    return _firestore
        .collection('volunteer_registrations')
        .where('userId', isEqualTo: userId)
        .orderBy('registeredAt', descending: true)
        .snapshots();
  }

  // ========== Search and Discovery ==========
  
  // Search NGOs by name or cause
  Future<QuerySnapshot> searchNGOs(String query) async {
    return await _firestore
        .collection('ngos')
        .where('isVerified', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  // Get featured/recommended opportunities
  Stream<QuerySnapshot> getFeaturedOpportunities() {
    return _firestore
        .collection('donation_requests')
        .where('status', isEqualTo: 'active')
        .where('urgencyLevel', isEqualTo: 'high')
        .limit(10)
        .snapshots();
  }

  // ========== ADMIN DASHBOARD METHODS ==========
  
  // Get all NGO members for admin dashboard (no ngoId filter)
  Stream<QuerySnapshot> getAllNGOMembers() {
    return _firestore
        .collection('ngo_members')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get all NGOs for admin dashboard
  Stream<QuerySnapshot> getAllNGOs() {
    return _firestore
        .collection('ngos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete NGO (admin only)
  Future<void> deleteNGO(String ngoId) async {
    try {
      await _firestore.collection('ngos').doc(ngoId).delete();
      print('NGO deleted successfully');
    } catch (e) {
      print('Error deleting NGO: $e');
      throw 'Failed to delete NGO';
    }
  }

  // Delete NGO member (admin only)
  Future<void> deleteNGOMember(String memberId) async {
    try {
      await _firestore.collection('ngo_members').doc(memberId).delete();
      print('NGO member deleted successfully');
    } catch (e) {
      print('Error deleting NGO member: $e');
      throw 'Failed to delete NGO member';
    }
  }

  // ============ ADMIN MANAGEMENT ============
  
  // Create admin document
  Future<void> createAdmin(AdminModel admin) async {
    try {
      await _firestore.collection('admins').doc(admin.uid).set(admin.toMap());
      print('Admin created successfully');
    } catch (e) {
      print('Error creating admin: $e');
      throw 'Failed to create admin profile';
    }
  }
  
  // Get admin by ID
  Future<AdminModel?> getAdminById(String adminId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(adminId).get();
      if (doc.exists) {
        return AdminModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting admin: $e');
      return null;
    }
  }
  
  // Get admin by email
  Future<AdminModel?> getAdminByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return AdminModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting admin by email: $e');
      return null;
    }
  }
  
  // Get all admins
  Future<List<AdminModel>> getAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('admins').get();
      return snapshot.docs.map((doc) {
        return AdminModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting admins: $e');
      return [];
    }
  }
  
  // Update admin profile
  Future<void> updateAdmin(String adminId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('admins').doc(adminId).update(updates);
      print('Admin updated successfully');
    } catch (e) {
      print('Error updating admin: $e');
      throw 'Failed to update admin profile';
    }
  }
  
  // Update admin last action timestamp
  Future<void> updateAdminLastAction(String adminId) async {
    try {
      await _firestore.collection('admins').doc(adminId).update({
        'lastAdminAction': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating admin last action: $e');
    }
  }
  
  // Stream of admins by role
  Stream<QuerySnapshot> getAdminsByRole(String role) {
    return _firestore
        .collection('admins')
        .where('role', isEqualTo: role)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }
  
  // Delete admin (super admin only)
  Future<void> deleteAdmin(String adminId) async {
    try {
      await _firestore.collection('admins').doc(adminId).delete();
      print('Admin deleted successfully');
    } catch (e) {
      print('Error deleting admin: $e');
      throw 'Failed to delete admin';
    }
  }

  // ============ COLLECTION STATISTICS ============
  
  // Get collection counts for dashboard
  Future<Map<String, int>> getCollectionStats() async {
    try {
      final usersCount = await _firestore.collection('users').get().then((snapshot) => snapshot.docs.length);
      final ngoMembersCount = await _firestore.collection('ngo_members').get().then((snapshot) => snapshot.docs.length);
      final adminsCount = await _firestore.collection('admins').get().then((snapshot) => snapshot.docs.length);
      final ngosCount = await _firestore.collection('ngos').get().then((snapshot) => snapshot.docs.length);
      
      return {
        'users': usersCount,
        'ngo_members': ngoMembersCount,
        'admins': adminsCount,
        'ngos': ngosCount,
      };
    } catch (e) {
      print('Error getting collection stats: $e');
      return {
        'users': 0,
        'ngo_members': 0,
        'admins': 0,
        'ngos': 0,
      };
    }
  }
}
