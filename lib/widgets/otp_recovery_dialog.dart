import 'package:flutter/material.dart';

class OTPRecoveryDialog extends StatelessWidget {
  const OTPRecoveryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            'OTP Issues?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'If you\'re not receiving OTP messages, try these solutions:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            
            _SolutionItem(
              icon: Icons.access_time,
              title: 'Rate Limiting Active',
              description: 'Firebase has temporarily blocked this device. Wait 24 hours before trying again.',
            ),
            
            _SolutionItem(
              icon: Icons.phone_android,
              title: 'Try Different Number',
              description: 'Use a different phone number that hasn\'t been tested recently.',
            ),
            
            _SolutionItem(
              icon: Icons.bug_report,
              title: 'Use Debug Mode',
              description: 'Go to splash screen and tap the logo 5 times rapidly to access debugging tools.',
            ),
            
            _SolutionItem(
              icon: Icons.format_list_numbered,
              title: 'Check Number Format',
              description: 'Use 10 digits only (e.g., 9876543210). Don\'t include +91 or spaces.',
            ),
            
            _SolutionItem(
              icon: Icons.support_agent,
              title: 'Contact Support',
              description: 'If the issue persists, contact our support team with error details.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/otp-debug');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B2CBF),
            foregroundColor: Colors.white,
          ),
          child: const Text('Open Debug'),
        ),
      ],
    );
  }
}

class _SolutionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SolutionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF7B2CBF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
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
}
