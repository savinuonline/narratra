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
              // Navigate to settings page
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
                // Profile Picture (Left Side)
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
                const SizedBox(width: 20), // Space between profile and text
                // Name & Edit Profile (Right Side)
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
                _navigateToFavoritesPage(context);
              },
            ),
            const SizedBox(height: 10), // Consistent gap
            FeatureTile(
              title: "Downloads",
              icon: Icons.download,
              onTap: () {
                _navigateToDownloadsPage(context);
              },
            ),
            const SizedBox(height: 10), // Consistent gap
            FeatureTile(
              title: "Rewards",
              icon: Icons.star_border,
              onTap: () {
                _navigateToRewardsPage(context);
              },
            ),
            const SizedBox(height: 10), // Consistent gap
            LanguageSelectionTile(
              title: "Language Selection",
              icon: Icons.language,
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            const SizedBox(height: 10), // Consistent gap
            SubscriptionTile(
              // Subscription feature added
              title: "Subscription",
              icon: Icons.subscriptions,
              onTap: () {
                // Navigate to Subscription page
                _navigateToSubscriptionPage(context);
              },
            ),
            const SizedBox(height: 10), // Consistent gap
            FeatureTile(
              title: "History",
              icon: Icons.history,
              onTap: () {
                _navigateToHistoryPage(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to navigate to the Favorites page
  void _navigateToFavoritesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesPage()),
    );
  }

  // Method to navigate to the Downloads page
  void _navigateToDownloadsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DownloadsPage()),
    );
  }

  // Method to navigate to the Rewards page
  void _navigateToRewardsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RewardsPage()),
    );
  }

  // Method to navigate to the Subscription page
  void _navigateToSubscriptionPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionPage()),
    );
  }

  // Method to navigate to the History page
  void _navigateToHistoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  // Method to show language selection dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  // Logic to change language to English
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Sinhala"),
                onTap: () {
                  // Logic to change language to Sinhala
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Tamil"),
                onTap: () {
                  // Logic to change language to Tamil
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
              style: TextStyle(
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

class LanguageSelectionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const LanguageSelectionTile({
    required this.title,
    required this.icon,
    required this.onTap,
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
              style: TextStyle(
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

class SubscriptionTile extends StatelessWidget {
  // Subscription Tile
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const SubscriptionTile({
    required this.title,
    required this.icon,
    required this.onTap,
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
              style: TextStyle(
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

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: const Color.fromARGB(255, 159, 173, 197),
      ),
      body: const Center(child: Text(" ", style: TextStyle(fontSize: 18))),
    );
  }
}

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
        backgroundColor: const Color.fromARGB(255, 159, 173, 197),
      ),
      body: const Center(child: Text(" ", style: TextStyle(fontSize: 18))),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: const Color.fromARGB(255, 159, 173, 197),
      ),
      body: const Center(child: Text(" ", style: TextStyle(fontSize: 18))),
    );
  }
}

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards"),
        backgroundColor: const Color.fromARGB(255, 159, 173, 197),
      ),
      body: const Center(child: Text(" ", style: TextStyle(fontSize: 18))),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  // Subscription page added
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscription"),
        backgroundColor: const Color.fromARGB(255, 159, 173, 197),
      ),
      body: const Center(child: Text(" ", style: TextStyle(fontSize: 18))),
    );
  }
}
