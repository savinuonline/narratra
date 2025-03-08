import 'package:flutter/material.dart';
import 'package:frontend/screens/rewards/referral_tab.dart';

class NavigationModule extends StatefulWidget {
  const NavigationModule({super.key});

  @override
  _NavigationModuleState createState() => _NavigationModuleState();
}

class _NavigationModuleState extends State<NavigationModule> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [ReferralTab()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/Home.svg', width: 24, height: 24),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/Search.svg', width: 24, height: 24),
            label: "Search",
          ),
          BottomNavigationBarItem(icon: Image.asset('assets/icons/Library.svg', width: 24, height: 24),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/Profile.svg',width: 24, height: 24,),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
