import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/app_models.dart';
import 'create_ngo_screen.dart';
import 'ngo_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.business),
              text: 'NGOs',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Members',
            ),
            Tab(
              icon: Icon(Icons.pending),
              text: 'Pending',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNGOsTab(),
          _buildMembersTab(),
          _buildPendingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateNGO(context),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNGOsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllNGOs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final ngos = snapshot.data?.docs ?? [];

        if (ngos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No NGOs registered yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first NGO to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ngos.length,
          itemBuilder: (context, index) {
            final ngoData = ngos[index].data() as Map<String, dynamic>;
            final ngo = NGOModel.fromFirestore(ngoData, ngos[index].id);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToNGOManagement(ngo),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2E7D32),
                    child: Text(
                      ngo.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    ngo.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${ngo.category}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Code: ${ngo.ngoCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${ngo.memberCount} members',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'manage',
                        child: Row(
                          children: [
                            Icon(Icons.settings, size: 20),
                            SizedBox(width: 8),
                            Text('Manage'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'manage') {
                        _navigateToNGOManagement(ngo);
                      } else if (value == 'edit') {
                        _showEditNGODialog(context, ngo);
                      } else if (value == 'delete') {
                        _showDeleteNGOConfirmation(context, ngo);
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMembersTab() {
    return FutureBuilder<List<NGOModel>>(
      future: _getAllNGOs(),
      builder: (context, ngoSnapshot) {
        if (ngoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ngoSnapshot.hasError) {
          return Center(child: Text('Error loading NGOs: ${ngoSnapshot.error}'));
        }

        final ngos = ngoSnapshot.data ?? [];

        if (ngos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No NGOs created yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAllNGOMembers(),
          builder: (context, memberSnapshot) {
            if (memberSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (memberSnapshot.hasError) {
              return Center(child: Text('Error loading members: ${memberSnapshot.error}'));
            }

            final allMembers = memberSnapshot.data?.docs ?? [];
            
            // Group verified members by NGO
            Map<String, List<NGOMemberModel>> membersByNGO = {};
            for (var doc in allMembers) {
              final member = NGOMemberModel.fromFirestore(doc);
              if (member.isVerified && member.approvalStatus == 'approved') {
                if (!membersByNGO.containsKey(member.ngoId)) {
                  membersByNGO[member.ngoId] = [];
                }
                membersByNGO[member.ngoId]!.add(member);
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ngos.length,
              itemBuilder: (context, index) {
                final ngo = ngos[index];
                final ngoMembers = membersByNGO[ngo.id] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Text(
                        ngo.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      ngo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      '${ngoMembers.length} verified member${ngoMembers.length != 1 ? 's' : ''} • Code: ${ngo.ngoCode}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    children: [
                      if (ngoMembers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No verified members yet',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ...ngoMembers.map((member) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 20,
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          title: Text(member.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Position: ${member.position}'),
                              Text('Email: ${member.email}'),
                              if (member.department.isNotEmpty)
                                Text('Department: ${member.department}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'view') {
                                    _showMemberDetailsDialog(context, member);
                                  } else if (value == 'remove') {
                                    _removeMemberFromNGO(context, member);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility, size: 16),
                                        SizedBox(width: 8),
                                        Text('View Details'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.remove_circle, size: 16, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Remove Member'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )).toList(),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method to get all NGOs
  Future<List<NGOModel>> _getAllNGOs() async {
    try {
      final snapshot = await _firestoreService.getAllNGOs().first;
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NGOModel.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting NGOs: $e');
      return [];
    }
  }

  // Show member details dialog
  void _showMemberDetailsDialog(BuildContext context, NGOMemberModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${member.email}'),
              Text('Phone: ${member.phone}'),
              Text('Position: ${member.position}'),
              if (member.department.isNotEmpty)
                Text('Department: ${member.department}'),
              Text('NGO: ${member.ngoName ?? 'N/A'}'),
              Text('NGO Code: ${member.ngoCode ?? 'N/A'}'),
              Text('Status: ${member.isVerified ? 'Verified' : 'Pending'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Remove member from NGO
  void _removeMemberFromNGO(BuildContext context, NGOMemberModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove "${member.name}" from this NGO?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteNGOMember(member.uid);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.name} has been removed!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error removing member: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: member.isVerified ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: member.isVerified ? Colors.green : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                member.isVerified ? Icons.verified : Icons.pending,
                                size: 16,
                                color: member.isVerified ? Colors.green[700] : Colors.orange[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                member.isVerified ? 'Verified' : 'Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: member.isVerified ? Colors.green[700] : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Contact Information Section
                    _buildInfoSection('Contact Information', [
                      _buildInfoRow(Icons.email, 'Email', member.email),
                      _buildInfoRow(Icons.phone, 'Phone', member.phone.isEmpty ? 'Not provided' : member.phone),
                      if (member.emergencyContact.isNotEmpty)
                        _buildInfoRow(Icons.contact_emergency, 'Emergency Contact', member.emergencyContact),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // NGO Information Section
                    _buildInfoSection('NGO Information', [
                      _buildInfoRow(Icons.business, 'NGO Name', member.ngoName ?? 'Not specified'),
                      _buildInfoRow(Icons.confirmation_number, 'NGO Code', member.ngoCode ?? 'N/A'),
                      if (member.department.isNotEmpty)
                        _buildInfoRow(Icons.domain, 'Department', member.department),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Professional Information Section
                    _buildInfoSection('Professional Details', [
                      if (member.employeeId.isNotEmpty)
                        _buildInfoRow(Icons.badge, 'Employee ID', member.employeeId),
                      if (member.workSchedule.isNotEmpty)
                        _buildInfoRow(Icons.schedule, 'Work Schedule', member.workSchedule),
                      if (member.responsibilities.isNotEmpty)
                        _buildInfoRow(Icons.task, 'Responsibilities', member.responsibilities.join(', ')),
                      if (member.permissions.isNotEmpty)
                        _buildInfoRow(Icons.security, 'Permissions', member.permissions.join(', ')),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Account Information Section
                    _buildInfoSection('Account Details', [
                      _buildInfoRow(Icons.person, 'User ID', member.uid),
                      _buildInfoRow(Icons.date_range, 'Created At', 
                        member.createdAt != null ? _formatDate(member.createdAt!) : 'Not available'),
                      if (member.joinedAt != null)
                        _buildInfoRow(Icons.work, 'Joined NGO', _formatDate(member.joinedAt!)),
                      if (member.lastLogin != null)
                        _buildInfoRow(Icons.access_time, 'Last Login', _formatDate(member.lastLogin!)),
                      _buildInfoRow(Icons.toggle_on, 'Account Status', member.isActive ? 'Active' : 'Inactive'),
                    ]),
                    
                    // Action Buttons
                    if (!member.isVerified) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _verifyMember(context, member),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Verify Member'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _rejectMember(context, member),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllNGOMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allMembers = snapshot.data?.docs ?? [];
        final pendingMembers = allMembers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['approvalStatus'] == 'pending' || 
                 (data['isVerified'] == false && data['approvalStatus'] == null);
        }).toList();

        if (pendingMembers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No pending members',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingMembers.length,
          itemBuilder: (context, index) {
            final member = NGOMemberModel.fromFirestore(pendingMembers[index]);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    member.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'NGO: ${member.ngoName ?? 'Not specified'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${member.ngoCode ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Email: ${member.email}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _verifyMember(context, member),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectMember(context, member),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToCreateNGO(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateNGOScreen(),
      ),
    );
    
    // If NGO was created successfully, refresh the list
    if (result == true) {
      setState(() {
        // This will trigger a rebuild and refresh the NGO list
      });
    }
  }

  void _navigateToNGOManagement(NGOModel ngo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NGOManagementScreen(ngo: ngo),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to login
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditNGODialog(BuildContext context, NGOModel ngo) {
    final nameController = TextEditingController(text: ngo.name);
    final categoryController = TextEditingController(text: ngo.category);
    final descriptionController = TextEditingController(text: ngo.description);
    final locationController = TextEditingController(text: ngo.location);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit NGO'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'NGO Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter NGO name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.vpn_key, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Text(
                        'NGO Code: ${ngo.ngoCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final updatedNGO = ngo.copyWith(
                    name: nameController.text.trim(),
                    category: categoryController.text.trim(),
                    description: descriptionController.text.trim(),
                    location: locationController.text.trim(),
                    lastUpdated: DateTime.now(),
                  );

                  await _firestoreService.updateNGO(ngo.id, updatedNGO.toFirestore());
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('NGO updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating NGO: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNGOConfirmation(BuildContext context, NGOModel ngo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete NGO'),
        content: Text('Are you sure you want to delete "${ngo.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteNGO(ngo.id);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('NGO deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting NGO: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _verifyMember(BuildContext context, NGOMemberModel member) async {
    try {
      await _firestoreService.updateNGOMember(member.uid, {
        'isVerified': true,
        'approvalStatus': 'approved',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} has been verified!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectMember(BuildContext context, NGOMemberModel member) async {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject "${member.name}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Please provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Update member with rejection status instead of deleting
                await _firestoreService.updateNGOMember(member.uid, {
                  'approvalStatus': 'rejected',
                  'rejectionReason': reasonController.text.trim().isEmpty 
                    ? 'Application rejected by admin' 
                    : reasonController.text.trim(),
                  'isVerified': false,
                  'lastUpdated': FieldValue.serverTimestamp(),
                });
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.name} has been rejected!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error rejecting member: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper methods for building member information display
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
