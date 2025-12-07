import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/music/presentation/bloc/song_bloc.dart';
import '../../features/music/presentation/bloc/player_bloc.dart';
import '../../features/music/domain/repositories/song_repository.dart';
import '../../features/music/data/repositories/song_repository_impl.dart';
import '../../features/music/data/models/song_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  await Hive.initFlutter();
  debugPrint('Hive initialized.');

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SongModelAdapter());

  final userBox = await Hive.openBox<UserModel>('user');
  final usersDbBox = await Hive.openBox('users_db');
  final songsBox = await Hive.openBox<SongModel>('songs');

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

  // Features - Music
  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(songsBox));
  sl.registerFactory(() => SongBloc(sl()));
  sl.registerFactory(() => PlayerBloc());
}
