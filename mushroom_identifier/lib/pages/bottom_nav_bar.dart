import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    _pages = [const HomeScreen(), const HistoryScreen()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final curveAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curveAnimation,
            child: child,
          );
        },
        child: Stack(
          key: ValueKey<int>(_selectedIndex),
          children: _pages.asMap().entries.map((entry) {
            int index = entry.key;
            Widget page = entry.value;
            return Offstage(
              offstage:_selectedIndex != index,
              child: TickerMode(
                enabled: _selectedIndex == index,
                child: page,
              ),
            );
          }).toList(),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History"
          ),
        ]
      )
    );
  }
}
