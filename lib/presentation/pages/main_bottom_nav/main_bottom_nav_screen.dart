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
    );
  }
}
