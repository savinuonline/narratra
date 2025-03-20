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

  final List<Widget> _pages = [
    HomeScreen(
      user: UserModel(
        uid: 'GEhVv1eBKM4VugcxFlVN',
        displayName: 'Test User',
        selectedGenres: ['Personal Growth', 'Fiction'],
      ),
    ),
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
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Colors.blue,
                unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
                selectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 10,
                iconSize: 26,
                items:
                    _navigationItems.map((item) {
                      final int index = _navigationItems.indexOf(item);
                      return BottomNavigationBarItem(
                        icon: Material(
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
                                final bool wasSelected =
                                    _previousIndex == index;
                                final double scale =
                                    isSelected ? _scaleAnimation.value : 1.0;
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
                        ),
                        label: item.label,
                      );
                    }).toList(),
              ),
            ),
          ),
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
