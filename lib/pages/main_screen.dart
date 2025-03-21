import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'library_page.dart';
import '../models/user_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  late UserModel currentUser;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUser = UserModel(
        uid: user.uid,
        displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
        selectedGenres: [],
      );
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  List<Widget> get _pages => [
    HomeScreen(user: currentUser),
    const Center(child: Text('Search')),
    const LibraryPage(),
    const Center(child: Text('Profile')),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(icon: 'Home.svg', label: 'Home'),
    NavigationItem(icon: 'Search.svg', label: 'Search'),
    NavigationItem(icon: 'Library.svg', label: 'Library'),
    NavigationItem(icon: 'Profile.svg', label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          // User is not authenticated, redirect to login
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              _pages[_selectedIndex],
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          _navigationItems.length,
                          (index) => _buildNavItem(index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: Colors.blue.withOpacity(0.2),
        highlightColor: Colors.blue.withOpacity(0.1),
        onTap: () => _onItemTapped(index),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final bool isSelected = _selectedIndex == index;
            final bool wasSelected = _previousIndex == index;
            final double scale = isSelected ? _scaleAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 1,
                ), // Changed from 1 to 0
                padding: const EdgeInsets.all(
                  6,
                ), // Changed from 7 to 6
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected
                          ? const Color(
                              0xff3dc2ec,
                            ).withOpacity(0.1)
                          : Colors.transparent,
                ),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: SvgPicture.asset(
                    'assets/icons/${item.icon}',
                    color:
                        isSelected
                            ? const Color(0xff3dc2ec)
                            : const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NavigationItem {
  final String icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
