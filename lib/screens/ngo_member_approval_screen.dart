import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import '../services/firestore_service.dart';
import 'ngo_dashboard_screen.dart';
import 'login_screen.dart';

class NGOMemberApprovalScreen extends StatefulWidget {
  const NGOMemberApprovalScreen({super.key});

  @override
  State<NGOMemberApprovalScreen> createState() => _NGOMemberApprovalScreenState();
}

class _NGOMemberApprovalScreenState extends State<NGOMemberApprovalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isRefreshing = false;
  NGOMemberModel? _memberData;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final memberData = await _firestoreService.getNGOMemberById(user.uid);
      if (memberData != null) {
        setState(() {
          _memberData = memberData;
        });

        // Check approval status and navigate accordingly
        if (memberData.approvalStatus == 'approved') {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NGODashboardScreen(),
              ),
            );
          }
        } else if (memberData.approvalStatus == 'rejected') {
          // Show rejection reason and allow re-application
          _showRejectionDialog(memberData.rejectionReason);
        }
      }
    } catch (e) {
      print('Error checking approval status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    await _checkApprovalStatus();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _showRejectionDialog(String? rejectionReason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 64,
        ),
        title: const Text(
          'Application Rejected',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your NGO membership application has been rejected by the admin.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rejectionReason,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('NGO Membership Status'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Pending Approval',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Your NGO membership application is under review by the admin.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'You will be notified once your application is approved.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Member Information Card
              if (_memberData != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Application Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Name', _memberData!.name),
                        _buildInfoRow('Email', _memberData!.email),
                        _buildInfoRow('NGO Name', _memberData!.ngoName ?? 'N/A'),
                        _buildInfoRow('NGO Code', _memberData!.ngoCode ?? 'N/A'),
                        _buildInfoRow('Applied On', 
                          _memberData!.appliedAt != null 
                            ? _formatDate(_memberData!.appliedAt!)
                            : 'N/A'
                        ),
                        _buildInfoRow('Status', 'Pending Review', isStatus: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Refresh Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isRefreshing ? null : _refreshStatus,
                  icon: _isRefreshing 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                  label: Text(
                    _isRefreshing ? 'Checking Status...' : 'Refresh Status',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help Text
              Text(
                'If you have any questions, please contact the admin.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (isStatus) ...[
                  Icon(
                    Icons.pending,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isStatus ? Colors.orange : const Color(0xFF333333),
                      fontWeight: isStatus ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
