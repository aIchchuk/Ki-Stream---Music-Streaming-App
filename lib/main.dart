import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const KiStreamApp());
}

class KiStreamApp extends StatelessWidget {
  const KiStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'KiStream',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
