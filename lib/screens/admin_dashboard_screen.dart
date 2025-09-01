import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/optimized_auth_service.dart';
import '../models/app_models.dart';
import 'create_ngo_screen.dart';
import 'ngo_management_screen.dart';
import '../splash_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final OptimizedAuthService _authService = OptimizedAuthService();
  
  // Add keys for refresh indicators
  final GlobalKey<RefreshIndicatorState> _ngosRefreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _membersRefreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _pendingRefreshKey = GlobalKey<RefreshIndicatorState>();

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

  // Refresh methods for each tab
  Future<void> _refreshNGOs() async {
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    // Force rebuild by calling setState
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshPending() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
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
          RefreshIndicator(
            key: _ngosRefreshKey,
            onRefresh: _refreshNGOs,
            child: _buildNGOsTab(),
          ),
          RefreshIndicator(
            key: _membersRefreshKey,
            onRefresh: _refreshMembers,
            child: _buildMembersTab(),
          ),
          RefreshIndicator(
            key: _pendingRefreshKey,
            onRefresh: _refreshPending,
            child: _buildPendingTab(),
          ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshNGOs(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final ngos = snapshot.data?.docs ?? [];

        if (ngos.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(
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
                      'Pull down to refresh or create your first NGO',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${ngo.category}',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
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
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestoreService.getAllNGOMembers(),
                              builder: (context, snapshot) {
                                int memberCount = 0;
                                if (snapshot.hasData) {
                                  // Count only verified and approved members for this specific NGO
                                  memberCount = snapshot.data!.docs.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return data['ngoId'] == ngo.id && 
                                           data['isVerified'] == true && 
                                           data['approvalStatus'] == 'approved';
                                  }).length;
                                }
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$memberCount member${memberCount != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading NGOs: ${ngoSnapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshMembers(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final ngos = ngoSnapshot.data ?? [];

        if (ngos.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No NGOs created yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAllNGOMembers(),
          builder: (context, memberSnapshot) {
            if (memberSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (memberSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading members: ${memberSnapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _refreshMembers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final allMembers = memberSnapshot.data?.docs ?? [];
            
            // Group verified members by NGO - Only show approved and verified members
            Map<String, List<NGOMemberModel>> membersByNGO = {};
            for (var doc in allMembers) {
              final member = NGOMemberModel.fromFirestore(doc);
              // Only include members who are both verified AND approved
              if (member.isVerified == true && member.approvalStatus == 'approved') {
                if (!membersByNGO.containsKey(member.ngoId)) {
                  membersByNGO[member.ngoId] = [];
                }
                membersByNGO[member.ngoId]!.add(member);
              }
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      '${ngoMembers.length} verified member${ngoMembers.length != 1 ? 's' : ''} • Code: ${ngo.ngoCode}',
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                          title: Text(
                            member.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Position: ${member.position}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Email: ${member.email}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              if (member.department.isNotEmpty)
                                Text(
                                  'Department: ${member.department}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, color: Colors.green, size: 20),
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

  Widget _buildPendingTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getAllNGOMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshPending(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allMembers = snapshot.data?.docs ?? [];
        // Only show members with pending status or unverified with no status
        final pendingMembers = allMembers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final approvalStatus = data['approvalStatus'];
          final isVerified = data['isVerified'] ?? false;
          
          // Show if explicitly pending OR if unverified and no approval status set
          return approvalStatus == 'pending' || 
                 (isVerified == false && (approvalStatus == null || approvalStatus == ''));
        }).toList();

        if (pendingMembers.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(
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
                    SizedBox(height: 8),
                    Text(
                      'Pull down to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'NGO: ${member.ngoName ?? 'Not specified'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${member.ngoCode ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Email: ${member.email}',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                // Only decrement member count if the member was previously approved
                bool wasApproved = member.isVerified == true && member.approvalStatus == 'approved';
                
                await _firestoreService.deleteNGOMember(member.uid);
                
                // Update NGO member count if member was approved
                if (wasApproved) {
                  await _firestoreService.updateNGO(member.ngoId, {
                    'memberCount': FieldValue.increment(-1),
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });
                }
                
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
              Navigator.of(context).pop(); // Close dialog
              _logout(); // Call logout method
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
                  await _firestoreService.updateNGO(ngo.id, {
                    'name': nameController.text.trim(),
                    'category': categoryController.text.trim(),
                    'location': locationController.text.trim(),
                    'description': descriptionController.text.trim(),
                  });
                  
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
      // Update member approval status
      await _firestoreService.updateNGOMember(member.uid, {
        'isVerified': true,
        'approvalStatus': 'approved',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Update NGO member count
      await _firestoreService.updateNGO(member.ngoId, {
        'memberCount': FieldValue.increment(1),
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
}
