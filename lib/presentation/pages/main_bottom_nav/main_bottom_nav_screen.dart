import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/presentation/pages/main_bottom_nav/components/side_drawer.dart';
import 'package:navex/presentation/widgets/custom_switch.dart';

class MainBottomNavScreen extends StatefulWidget {
  const MainBottomNavScreen({super.key});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Navex',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CustomSwitch(
            value: isOnline,
            onChanged: (value) {
              setState(() {
                isOnline = value;
              });
            },
          ),

          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_rounded, size: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.kDefaultPadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppSizes.cardCornerRadius / 1.5,
              ),
              child: Image.network(
                'https://images.pexels.com/photos/1704488/pexels-photo-1704488.jpeg?cs=srgb&dl=pexels-sulimansallehi-1704488.jpg&fm=jpg',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      drawer: SideDrawer(),
      body: ListView(children: []),
    );
  }
}
