import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using Narratra, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
              '• Modify or copy the materials\n'
              '• Use the materials for any commercial purpose\n'
              '• Attempt to decompile or reverse engineer any software contained in the app\n'
              '• Remove any copyright or other proprietary notations from the materials\n'
              '• Transfer the materials to another person or "mirror" the materials on any other server',
            ),
            _buildSection(
              '3. User Account',
              'To access certain features of the app, you may be required to create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.',
            ),
            _buildSection(
              '4. Subscription and Payments',
              '• Some features of the app require a paid subscription\n'
              '• Subscription fees are billed in advance on a recurring basis\n'
              '• You can cancel your subscription at any time\n'
              '• Refunds are subject to our refund policy',
            ),
            _buildSection(
              '5. Content Usage',
              '• All audiobook content is licensed for personal use only\n'
              '• You may not share, distribute, or reproduce any content\n'
              '• Offline listening is permitted for personal use only\n'
              '• Content availability may vary by region',
            ),
            _buildSection(
              '6. User Conduct',
              'You agree not to:\n\n'
              '• Use the service for any illegal purpose\n'
              '• Violate any laws in your jurisdiction\n'
              '• Share your account credentials\n'
              '• Attempt to gain unauthorized access to any portion of the service\n'
              '• Interfere with or disrupt the service',
            ),
            _buildSection(
              '7. Disclaimer',
              'The materials on Narratra are provided on an \'as is\' basis. Narratra makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            _buildSection(
              '8. Limitations',
              'In no event shall Narratra or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Narratra.',
            ),
            _buildSection(
              '9. Revisions',
              'Narratra may revise these terms of service at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.',
            ),
            _buildSection(
              '10. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at:\n\n'
              'Email: support@narratra.com\n'
              'Address: No.10, Liyanage Road, Dehiwala, Colombo, Sri Lanka',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 