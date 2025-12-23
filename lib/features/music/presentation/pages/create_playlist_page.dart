import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/playlist_model.dart';
import '../bloc/playlist_bloc/playlist_bloc.dart';
import '../bloc/song_bloc.dart';
// ignore: unused_import
import '../../data/models/song_model.dart';

class CreatePlaylistPage extends StatefulWidget {
  const CreatePlaylistPage({super.key});

  @override
  State<CreatePlaylistPage> createState() => _CreatePlaylistPageState();
}

class _CreatePlaylistPageState extends State<CreatePlaylistPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _moodController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<String> _selectedSongIds = {};
  String? _imagePath;
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _moodController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _savePlaylist() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final mood = _moodController.text.trim();

      final playlist = PlaylistModel(
        id: const Uuid().v4(),
        name: name,
        mood: mood,
        songIds: _selectedSongIds.toList(),
        dateCreated: DateTime.now(),
        imagePath: _imagePath,
      );

      context.read<PlaylistBloc>().add(CreatePlaylist(playlist));
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Playlist '$name' created!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text("Create Playlist"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _savePlaylist,
            child: const Text(
              "Save",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Picker
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          image: _imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(_imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: _imagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey[400],
                                    size: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Add Cover",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Playlist Name",
                              hintText: "e.g., Road Trip",
                              labelStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter a name"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _moodController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Mood",
                              hintText: "e.g., Energetic, Chill",
                              labelStyle: TextStyle(color: Colors.grey),
                              helperText: "Used for default colors",
                              helperStyle: TextStyle(color: Colors.grey),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? "Enter a mood"
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Songs",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase();
                              });
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search songs...",
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<SongBloc, SongState>(
                      builder: (context, state) {
                        if (state is SongLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is SongLoaded) {
                          var songs = state.songs;
                          if (_searchQuery.isNotEmpty) {
                            songs = songs.where((s) {
                              return s.songName.toLowerCase().contains(
                                    _searchQuery,
                                  ) ||
                                  s.artistName.toLowerCase().contains(
                                    _searchQuery,
                                  );
                            }).toList();
                          }

                          if (songs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "No songs found.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final isSelected = _selectedSongIds.contains(
                                song.id,
                              );
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    song.songImage,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  song.songName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  song.artistName,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedSongIds.remove(song.id);
                                    } else {
                                      _selectedSongIds.add(song.id);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
