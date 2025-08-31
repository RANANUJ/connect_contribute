import 'package:flutter/material.dart';
import '../services/optimized_auth_service.dart';

class FirebaseCostMonitor extends StatefulWidget {
  const FirebaseCostMonitor({super.key});

  @override
  State<FirebaseCostMonitor> createState() => _FirebaseCostMonitorState();
}

class _FirebaseCostMonitorState extends State<FirebaseCostMonitor> {
  Map<String, int> _usageStats = {};

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }

  void _loadUsageStats() {
    setState(() {
      _usageStats = OptimizedAuthService.usageStats;
    });
  }

  void _resetStats() {
    OptimizedAuthService.resetUsageStats();
    _loadUsageStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usage statistics reset successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Approximate cost calculations based on Firebase pricing
  double _calculateFirestoreCost() {
    const costPerRead = 0.00006; // $0.06 per 100,000 reads
    const costPerWrite = 0.00018; // $0.18 per 100,000 writes
    
    final reads = _usageStats['firestore_reads'] ?? 0;
    final writes = _usageStats['firestore_writes'] ?? 0;
    
    return (reads * costPerRead) + (writes * costPerWrite);
  }

  double _calculateSmsCost() {
    const costPerSms = 0.01; // Approximate $0.01 per SMS
    final smsCount = _usageStats['sms_sent'] ?? 0;
    return smsCount * costPerSms;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreCost = _calculateFirestoreCost();
    final smsCost = _calculateSmsCost();
    final totalCost = firestoreCost + smsCost;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Firebase Usage Monitor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B2CBF),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadUsageStats,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      onPressed: _resetStats,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Reset Stats',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Usage Statistics
            _buildStatRow('Firestore Reads', '${_usageStats['firestore_reads'] ?? 0}', Icons.visibility),
            _buildStatRow('Firestore Writes', '${_usageStats['firestore_writes'] ?? 0}', Icons.edit),
            _buildStatRow('SMS Sent', '${_usageStats['sms_sent'] ?? 0}', Icons.sms),
            
            const Divider(height: 24),
            
            // Cost Estimates
            const Text(
              'Estimated Costs (USD)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildCostRow('Firestore Operations', firestoreCost),
            _buildCostRow('SMS/Phone Auth', smsCost),
            
            const Divider(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated Cost:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalCost.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totalCost > 1.0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cost optimization tips
            if (totalCost > 0.50) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Cost Optimization Tips',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Use caching to reduce Firestore reads\n'
                      '• Implement cooldowns for SMS OTP\n'
                      '• Use batch operations for writes\n'
                      '• Monitor usage regularly',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Great! Your usage is cost-efficient.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '\$${cost.toStringAsFixed(4)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
