import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/subscription.dart';
import '../screens/rewards/reward_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  UserProfile? _userProfile;
  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _firebaseService.getUserProfile();
      setState(() => _userProfile = profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _imageFile = File(image.path));
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      await _firebaseService.updateUserProfile(
        _userProfile!.copyWith(profileImageUrl: imageUrl),
      );

      setState(
        () => _userProfile = _userProfile!.copyWith(profileImageUrl: imageUrl),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showEditProfileDialog() async {
    final TextEditingController firstNameController = TextEditingController(
      text: _userProfile?.firstName ?? '',
    );
    final TextEditingController lastNameController = TextEditingController(
      text: _userProfile?.lastName ?? '',
    );
    final TextEditingController phoneController = TextEditingController(
      text: _userProfile?.phoneNumber ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: _userProfile?.email ?? '',
    );

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updatedProfile = _userProfile!.copyWith(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    phoneNumber: phoneController.text,
                  );

                  try {
                    await _firebaseService.updateUserProfile(updatedProfile);
                    setState(() => _userProfile = updatedProfile);
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating profile: $e')),
                      );
                    }
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageFile != null
                                ? FileImage(_imageFile!)
                                : (_userProfile?.profileImageUrl != null
                                        ? NetworkImage(
                                          _userProfile!.profileImageUrl!,
                                        )
                                        : const AssetImage(
                                          "lib/images/profile_picture.png",
                                        ))
                                    as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 12,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_userProfile?.firstName ?? ''} ${_userProfile?.lastName ?? ''}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _userProfile?.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: _showEditProfileDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            FeatureTile(
              title: "Favorites",
              icon: Icons.favorite_border,
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    '/library',
                    arguments: {'tab': 'favorites'},
                  ),
            ),
            FeatureTile(
              title: "Downloads",
              icon: Icons.download,
              onTap: () => Navigator.pushNamed(context, '/downloads'),
            ),
            FeatureTile(
              title: "Rewards",
              icon: Icons.star_border,
              onTap: () => Navigator.pushNamed(context, '/rewards'),
            ),
            FeatureTile(
              title: "Language Selection",
              icon: Icons.language,
              onTap: () => Navigator.pushNamed(context, '/language'),
            ),
            FeatureTile(
              title: "History",
              icon: Icons.history,
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            const SizedBox(height: 30),
            const Text(
              "About",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Privacy Policy",
              icon: Icons.privacy_tip,
              onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
            ),
            FeatureTile(
              title: "Terms of Service",
              icon: Icons.description,
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            FeatureTile(
              title: "Rate Narratra",
              icon: Icons.rate_review,
              onTap: () => Navigator.pushNamed(context, '/rate-app'),
            ),
            FeatureTile(
              title: "Settings",
              icon: Icons.settings,
              onTap: () => Navigator.pushNamed(context, '/settingsPage'),
            ),
            const SizedBox(height: 40),
            _buildSubscriptionInfo(_userProfile!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 72, 84),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo(UserProfile profile) {
    final subscription =
        profile.subscription ?? {'plan': 'free', 'status': 'inactive'};
    final isPremium = subscription['plan'] != 'free';
    final status = subscription['status'] ?? 'inactive';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscription',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPage(),
                    ),
                  ).then((_) => _loadUserProfile());
                },
                child: Text(
                  isPremium ? 'Manage Subscription' : 'Upgrade',
                  style: const TextStyle(
                    color: Color(0xFF402e7a),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPremium ? Icons.star : Icons.star_border,
                color: isPremium ? Colors.amber : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                isPremium ? 'Premium Plan' : 'Free Plan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (isPremium) ...[
            const SizedBox(height: 4),
            Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(
                color: status == 'active' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureTile({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 40, 37, 223)),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap,
    );
  }
}
