import 'package:flutter/material.dart';
import 'package:navex/app/global_bloc.dart';

import '../core/navigation/app_router.dart';
import '../core/themes/theme.dart';
import '../core/utils/snackbar_helper.dart';
import '../presentation/pages/spalsh/splash_screen.dart';

class NavexApp extends StatelessWidget {
  const NavexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalBloc(
      child: MaterialApp.router(
        title: 'Navex',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
        scaffoldMessengerKey: SnackBarHelper.messengerKey,
        builder: (context, routedChild){
          return Scaffold(
            body: routedChild,
          );
        },
      ),
    );
  }
}
