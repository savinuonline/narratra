import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
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
              'Introduction',
              'Welcome to Narratra. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
            ),
            _buildSection(
              'Data We Collect',
              'We collect and process the following information:\n\n'
              '• Personal identification information (name, email address, phone number)\n'
              '• Profile information (profile picture, preferences)\n'
              '• Usage data (listening history, bookmarks, favorites)\n'
              '• Device information (device type, operating system)\n'
              '• Location data (country/region for content availability)',
            ),
            _buildSection(
              'How We Use Your Data',
              'We use your personal data for the following purposes:\n\n'
              '• To provide and maintain our service\n'
              '• To notify you about changes to our service\n'
              '• To provide customer support\n'
              '• To gather analysis or valuable information to improve our service\n'
              '• To monitor the usage of our service\n'
              '• To detect, prevent and address technical issues',
            ),
            _buildSection(
              'Data Security',
              'We have implemented appropriate security measures to prevent your personal data from being accidentally lost, used, or accessed in an unauthorized way, altered, or disclosed.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct your personal data\n'
              '• Erase your personal data\n'
              '• Object to processing of your personal data\n'
              '• Request restriction of processing your personal data\n'
              '• Request transfer of your personal data\n'
              '• Right to withdraw consent',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at:\n\n'
              'Email: support@narratra.com\n'
              'Address: [Your Company Address]',
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