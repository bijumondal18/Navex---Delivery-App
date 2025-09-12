import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.27,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Stack(
              children: [
                SvgPicture.asset(AppImages.sideOval, fit: BoxFit.cover),
                SvgPicture.asset(AppImages.topOval, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.kDefaultPadding,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppSizes.kDefaultPadding,
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          radius: 54,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundImage: NetworkImage(
                              'https://t4.ftcdn.net/jpg/04/31/64/75/360_F_431647519_usrbQ8Z983hTYe8zgA7t1XVc5fEtqcpa.jpg',
                            ),
                          ),
                        ),
                        Text(
                          'Larry Davis',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Text('Home', style: Theme.of(context).textTheme.bodyLarge,),
            ],
          )
        ],
      ),
    );
  }
}
