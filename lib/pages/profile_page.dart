import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/profile.jpg"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 12,
                          ),
                          onPressed: () {
                            // Edit profile picture functionality
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mashinee Maleesha",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        // Edit profile functionality
                      },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PlaceholderPage(title: "Favorites"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Downloads",
              icon: Icons.download,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PlaceholderPage(title: "Downloads"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Rewards",
              icon: Icons.star_border,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PlaceholderPage(title: "Rewards"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Language Selection",
              icon: Icons.language,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PlaceholderPage(title: "Language Selection"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Subscription",
              icon: Icons.subscriptions,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const PlaceholderPage(title: "Subscription"),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "History",
              icon: Icons.history,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PlaceholderPage(title: "History"),
                  ),
                );
              },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Terms of Service",
              icon: Icons.description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServicePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            FeatureTile(
              title: "Rate Narratra",
              icon: Icons.rate_review,
              onTap: () {},
            ),
          ],
        ),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title Page Content Here")),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Center(child: Text("Privacy Policy Content Here")),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: const Center(child: Text("Terms of Service Content Here")),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(child: Text("Settings Page")),
    );
  }
}
