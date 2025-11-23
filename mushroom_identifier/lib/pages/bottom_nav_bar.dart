import 'package:FungiScan/pages/forage_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'history_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildNavItem(IconData icon, int index, ColorScheme colorScheme) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.jumpToPage(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha:0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha:0.7),
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomBar(
      borderRadius: BorderRadius.circular(25),
      duration: const Duration(milliseconds: 400),
      barColor: colorScheme.tertiary.withValues(alpha: 0.9),
      body: (context, controller) => PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          HomeScreen(),
          HistoryScreen(),
          SearchScreen(),
          ForageMapScreen(),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 0, colorScheme),
            _buildNavItem(Icons.history, 1, colorScheme),
            _buildNavItem(Icons.search, 2, colorScheme),
            _buildNavItem(Icons.map, 3, colorScheme),
          ],
        ),
      ),
    );
  }
}
