import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// A model class to represent each navigation item.
class NavigationItem {
  final String icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

/// A custom bottom navigation bar with animated scaling effect.
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> navigationItems;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.navigationItems,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
    widget.onTap(index);
    _animationController.forward().then((value) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
            currentIndex: widget.currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 0.9,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 0.9,
            ),
            backgroundColor: Colors.white,
            elevation: 10,
            iconSize: 28,
            items: widget.navigationItems.map((item) {
              final int index = widget.navigationItems.indexOf(item);
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
                        final bool isSelected = widget.currentIndex == index;
                        final double scale = isSelected ? _scaleAnimation.value : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: SvgPicture.asset(
                                'assets/icons/${item.icon}',
                                color:
                                isSelected
                                    ? Colors.blue
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
    );
  }
}
