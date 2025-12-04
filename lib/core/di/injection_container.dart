import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  await Hive.initFlutter();
  debugPrint('Hive initialized.');

  Hive.registerAdapter(UserModelAdapter());

  final userBox = await Hive.openBox<UserModel>('user');
  final usersDbBox = await Hive.openBox('users_db');

  debugPrint(
    'Hive Boxes opened. Session: ${userBox.length}, DB Users: ${usersDbBox.length}',
  );

  // External
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => userBox);
  sl.registerLazySingleton(() => usersDbBox);

  // Features - Auth
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl(), sl()),
  );
}
