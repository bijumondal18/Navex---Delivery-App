import 'package:flutter/material.dart';
import 'package:navex/presentation/pages/main_bottom_nav/components/side_drawer.dart';

class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: SideDrawer(),
      body: ListView(children: []),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: "Routes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person_2_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
