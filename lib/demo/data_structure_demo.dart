// Demo file showing the separate data storage structure for NGO members and users

import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';

class DataStructureDemo extends StatefulWidget {
  const DataStructureDemo({super.key});

  @override
  State<DataStructureDemo> createState() => _DataStructureDemoState();
}

class _DataStructureDemoState extends State<DataStructureDemo> {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<UserModel> _users = [];
  List<NGOMemberModel> _ngoMembers = [];
  List<NGOModel> _ngos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load regular users
      final users = await _firestoreService.getAllUsers();
      
      // Load NGOs  
      final ngosSnapshot = await _firestoreService.getNGOs().first;
      final ngos = ngosSnapshot.docs.map((doc) => NGOModel.fromFirestore(doc)).toList();
      
      // For demo purposes, we'll create sample NGO members
      // In real app, this would come from the ngo_members collection
      
      setState(() {
        _users = users;
        _ngos = ngos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Structure Demo'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Database Structure'),
                  _buildDataStructureInfo(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Regular Users Collection'),
                  _buildUsersSection(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('NGO Members Collection'),
                  _buildNGOMembersSection(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('NGOs Collection'),
                  _buildNGOsSection(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Demo Actions'),
                  _buildDemoActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF7B2CBF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7B2CBF),
        ),
      ),
    );
  }

  Widget _buildDataStructureInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firestore Collections:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildCollectionInfo('📁 users', 'Individual users (volunteers, donors)', Colors.blue),
            _buildCollectionInfo('📁 ngo_members', 'NGO staff and members', Colors.green),
            _buildCollectionInfo('📁 ngos', 'NGO organizations', Colors.orange),
            _buildCollectionInfo('📁 userStats', 'User activity statistics', Colors.purple),
            _buildCollectionInfo('📁 ngoMemberStats', 'NGO member performance', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionInfo(String name, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' - $description'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Users: ${_users.length}'),
            const SizedBox(height: 12),
            if (_users.isEmpty)
              const Text('No regular users registered yet')
            else
              ..._users.take(3).map((user) => _buildUserCard(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildNGOMembersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total NGO Members: ${_ngoMembers.length}'),
            const SizedBox(height: 12),
            if (_ngoMembers.isEmpty)
              const Text('No NGO members registered yet')
            else
              ..._ngoMembers.take(3).map((member) => _buildNGOMemberCard(member)),
          ],
        ),
      ),
    );
  }

  Widget _buildNGOsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total NGOs: ${_ngos.length}'),
            const SizedBox(height: 12),
            if (_ngos.isEmpty)
              const Text('No NGOs registered yet')
            else
              ..._ngos.take(3).map((ngo) => _buildNGOCard(ngo)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${user.userType.toUpperCase()} • ${user.email}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNGOMemberCard(NGOMemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.work, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${member.position.toUpperCase()} • NGO ID: ${member.ngoId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNGOCard(NGOModel ngo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ngo.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${ngo.category.toUpperCase()} • Members: ${ngo.totalMembers}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demo Actions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _createSampleUser,
              icon: const Icon(Icons.person_add),
              label: const Text('Create Sample User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _createSampleNGOMember,
              icon: const Icon(Icons.work_outline),
              label: const Text('Create Sample NGO Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2CBF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createSampleUser() async {
    try {
      final sampleUser = UserModel(
        uid: 'sample_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        userType: 'volunteer',
        address: '123 Main St, City, State',
        interests: ['education', 'environment'],
        skills: ['teaching', 'organizing'],
        occupation: 'Teacher',
      );

      await _firestoreService.createUser(sampleUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample user created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createSampleNGOMember() async {
    if (_ngos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create an NGO first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final sampleMember = NGOMemberModel(
        uid: 'sample_member_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Jane Smith',
        email: 'jane.smith@ngo.org',
        phone: '+1987654321',
        ngoId: _ngos.first.uid,
        position: 'coordinator',
        permissions: ['view', 'create', 'edit'],
        department: 'Community Outreach',
        responsibilities: ['Event Planning', 'Volunteer Coordination'],
        workSchedule: 'Full-time',
        emergencyContact: '+1555123456',
      );

      await _firestoreService.createNGOMember(sampleMember);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample NGO member created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating NGO member: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }
}
