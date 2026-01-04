import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/data/models/user_model.dart';
import '../../features/music/presentation/bloc/song_bloc.dart';
import '../../features/music/presentation/bloc/player_bloc.dart';
import '../../features/music/domain/repositories/song_repository.dart';
import '../../features/music/data/repositories/song_repository_impl.dart';
import '../../features/music/data/models/song_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/music/data/models/playlist_model.dart';
import '../../features/music/domain/repositories/playlist_repository.dart';
import '../../features/music/data/repositories/playlist_repository_impl.dart';
import '../../features/music/presentation/bloc/playlist_bloc/playlist_bloc.dart';
import '../../features/music/presentation/bloc/downloads_bloc.dart';

// Data Sources
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/music/data/datasources/music_local_data_source.dart';
import '../../features/music/data/datasources/music_remote_data_source.dart';
import '../network/server_health_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  await Hive.initFlutter();
  debugPrint('Hive initialized.');

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(SongModelAdapter());
  Hive.registerAdapter(PlaylistModelAdapter());

  final userBox = await Hive.openBox<UserModel>('user');
  final usersDbBox = await Hive.openBox('users_db');
  final songsBox = await Hive.openBox<SongModel>('songs');
  final downloadedSongsBox = await Hive.openBox<SongModel>('downloaded_songs');
  final playlistsBox = await Hive.openBox<PlaylistModel>('playlists');

  debugPrint(
    'Hive Boxes opened. Session: ${userBox.length}, DB Users: ${usersDbBox.length}, Playlists: ${playlistsBox.length}, Downloaded Songs: ${downloadedSongsBox.length}',
  );

  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => userBox);
  sl.registerLazySingleton(() => usersDbBox);

  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(userBox: sl(), usersDbBox: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<MusicLocalDataSource>(
    () => MusicLocalDataSourceImpl(
      songBox: songsBox,
      downloadedSongsBox: downloadedSongsBox,
      playlistBox: playlistsBox,
    ),
  );
  sl.registerLazySingleton<MusicRemoteDataSource>(
    () => MusicRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ServerHealthDataSource>(
    () => ServerHealthDataSourceImpl(client: sl()),
  );

  // Features - Auth
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      googleSignIn: sl(),
      localDataSource: sl(),
      remoteDataSource: sl(),
      serverHealthDataSource: sl(),
    ),
  );

  // Features - Music
  sl.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      serverHealthDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      serverHealthDataSource: sl(),
    ),
  );
  sl.registerFactory(() => SongBloc(sl()));
  sl.registerFactory(() => PlayerBloc());
  sl.registerFactory(() => PlaylistBloc(sl()));
  sl.registerFactory(() => DownloadsBloc(sl()));
}
