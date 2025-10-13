import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/data/repositories/auth_repository.dart';
import 'package:navex/presentation/bloc/auth_bloc.dart';

class GlobalBloc extends StatelessWidget {
  final Widget child;

  const GlobalBloc({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (create) => AuthBloc(AuthRepository())),
        //
      ],
      child: child,
    );
  }
}
