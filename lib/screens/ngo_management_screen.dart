import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';

class NGOManagementScreen extends StatefulWidget {
  final NGOModel ngo;

  const NGOManagementScreen({super.key, required this.ngo});

  @override
  State<NGOManagementScreen> createState() => _NGOManagementScreenState();
}

class _NGOManagementScreenState extends State<NGOManagementScreen> with TickerProviderStateMixin {
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
        title: Text(widget.ngo.name),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditNGODialog(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _confirmDeleteNGO();
                  break;
                case 'deactivate':
                  _toggleNGOStatus();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Deactivate NGO'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete NGO'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildMembersTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showAddMemberDialog(),
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NGO Code Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organization Code',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      widget.ngo.ngoCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _copyToClipboard(widget.ngo.ngoCode),
                      icon: const Icon(Icons.copy, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share this code with members to join your organization',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Basic Information
          _buildInfoCard(
            title: 'Basic Information',
            children: [
              _buildInfoRow('Category', widget.ngo.category),
              _buildInfoRow('Location', widget.ngo.location),
              _buildInfoRow('Established', widget.ngo.establishedYear.toString()),
              _buildInfoRow('Status', widget.ngo.isVerified ? 'Verified' : 'Pending'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          _buildInfoCard(
            title: 'Description',
            children: [
              Text(
                widget.ngo.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Activities
          if (widget.ngo.activities.isNotEmpty)
            _buildInfoCard(
              title: 'Main Activities',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.ngo.activities.map((activity) => Chip(
                    label: Text(activity),
                    backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                    labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
                  )).toList(),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          _buildInfoCard(
            title: 'Contact Information',
            children: [
              _buildInfoRow('Email', widget.ngo.contactEmail),
              _buildInfoRow('Phone', widget.ngo.contactPhone),
              if (widget.ngo.website.isNotEmpty)
                _buildInfoRow('Website', widget.ngo.website),
              if (widget.ngo.registrationNumber.isNotEmpty)
                _buildInfoRow('Registration', widget.ngo.registrationNumber),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Social Media
          if (widget.ngo.socialMediaLinks.isNotEmpty)
            _buildInfoCard(
              title: 'Social Media',
              children: [
                ...widget.ngo.socialMediaLinks.entries.map((entry) =>
                  _buildInfoRow(
                    entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                    entry.value,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return FutureBuilder<List<NGOMemberModel>>(
      future: _firestoreService.getNGOMembers(widget.ngo.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No members yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add members to start building your team',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2E7D32),
                  child: Text(
                    member.name.isNotEmpty 
                        ? member.name[0].toUpperCase()
                        : 'M',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.email),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(member.position).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        member.position,
                        style: TextStyle(
                          color: _getRoleColor(member.position),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMemberAction(value, member),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit_role',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view_details',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove Member'),
                        ],
                      ),
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

  Widget _buildAnalyticsTab() {
    return FutureBuilder<List<NGOMemberModel>>(
      future: _firestoreService.getNGOMembers(widget.ngo.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data ?? [];
        final roleStats = <String, int>{};
        
        for (var member in members) {
          roleStats[member.position] = (roleStats[member.position] ?? 0) + 1;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Members',
                      value: members.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Roles',
                      value: roleStats.length.toString(),
                      icon: Icons.work,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Role Distribution
              if (roleStats.isNotEmpty) ...[
                const Text(
                  'Member Role Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: roleStats.entries.map((entry) => 
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getRoleColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // NGO Information Summary
              const Text(
                'Organization Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Key Metrics',
                children: [
                  _buildInfoRow('Created', _formatDate(widget.ngo.createdAt)),
                  _buildInfoRow('Last Updated', _formatDate(widget.ngo.lastUpdated)),
                  _buildInfoRow('Total Activities', widget.ngo.activities.length.toString()),
                  _buildInfoRow('Verification Status', widget.ngo.isVerified ? 'Verified' : 'Pending'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return Colors.red;
      case 'manager':
      case 'coordinator':
        return Colors.orange;
      case 'volunteer':
        return Colors.blue;
      case 'member':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _copyToClipboard(String text) {
    // Implementation for copying to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _handleMemberAction(String action, NGOMemberModel member) {
    switch (action) {
      case 'edit_role':
        _showChangeRoleDialog(member);
        break;
      case 'view_details':
        _showMemberDetailsDialog(member);
        break;
      case 'remove':
        _confirmRemoveMember(member);
        break;
    }
  }

  void _showChangeRoleDialog(NGOMemberModel member) {
    final roles = ['Member', 'Volunteer', 'Coordinator', 'Manager', 'Administrator'];
    String selectedRole = member.position;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Role for ${member.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select new role:'),
              const SizedBox(height: 16),
              ...roles.map((role) => RadioListTile<String>(
                title: Text(role),
                value: role,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestoreService.updateNGOMember(member.uid, {'position': selectedRole});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Role updated to $selectedRole'),
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating role: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetailsDialog(NGOMemberModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', member.email),
              _buildDetailRow('Phone', member.phone),
              _buildDetailRow('Position', member.position),
              _buildDetailRow('Department', member.department),
              _buildDetailRow('Employee ID', member.employeeId.isNotEmpty ? member.employeeId : 'Not assigned'),
              _buildDetailRow('Work Schedule', member.workSchedule.isNotEmpty ? member.workSchedule : 'Not specified'),
              _buildDetailRow('Emergency Contact', member.emergencyContact.isNotEmpty ? member.emergencyContact : 'Not provided'),
              _buildDetailRow('Responsibilities', member.responsibilities.join(', ')),
              _buildDetailRow('Joined', member.joinedAt != null ? _formatDate(member.joinedAt!) : 'Not specified'),
              _buildDetailRow('Created', member.createdAt != null ? _formatDate(member.createdAt!) : 'Not available'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 2),
          Text(value.isEmpty ? 'Not provided' : value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmRemoveMember(NGOMemberModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.name} from this NGO?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestoreService.deleteNGOMember(member.uid);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Member removed successfully'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
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

  void _showAddMemberDialog() {
    final emailController = TextEditingController();
    final roleController = TextEditingController(text: 'Member');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Member Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: roleController.text,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['Member', 'Volunteer', 'Coordinator', 'Manager']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  roleController.text = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Implementation for adding member
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member invitation sent'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _showEditNGODialog() {
    // Implementation for editing NGO details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit NGO feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _confirmDeleteNGO() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete NGO'),
        content: Text('Are you sure you want to delete "${widget.ngo.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementation for deleting NGO
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('NGO deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleNGOStatus() {
    // Implementation for toggling NGO active status
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('NGO status updated'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }
}
