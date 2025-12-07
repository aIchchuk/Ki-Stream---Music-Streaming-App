import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/song_model.dart';
import '../bloc/song_bloc.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  bool _isManualMode = false;

  // Link Mode Controllers
  final _linkController = TextEditingController();
  final _linkAlbumController = TextEditingController();

  // Manual Mode Controllers
  final _manualNameController = TextEditingController();
  final _manualArtistController = TextEditingController();
  final _manualAlbumController = TextEditingController();

  String? _pickedImagePath;
  String? _pickedAudioPath;

  final String _mockImage =
      "https://picsum.photos/400/600?random=${DateTime.now().millisecond}";
  final String _mockTitle = "New Song";
  final String _mockArtist = "Unknown Artist";
  final String _mockAlbum = "Single";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text("Add Song", style: TextStyle(color: Colors.white)),
      ),
      body: BlocListener<SongBloc, SongState>(
        listener: (context, state) {
          if (state is SongLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Song Added to Library!')),
            );
            context.pop();
          } else if (state is SongError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModeToggle(),
              const SizedBox(height: 30),
              if (!_isManualMode) _buildLinkMode() else _buildManualMode(),
              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _onAddSong,
                  child: const Text(
                    'Add Song',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isManualMode = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isManualMode
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Link",
                  style: TextStyle(
                    color: !_isManualMode ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isManualMode = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isManualMode
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Manual",
                  style: TextStyle(
                    color: _isManualMode ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Song URL',
          controller: _linkController,
          hint: 'Paste direct audio link',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Album Name (Optional)',
          controller: _linkAlbumController,
          hint: 'Enter album name',
        ),
        const SizedBox(height: 30),
        const Text(
          "Preview",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: NetworkImage(_mockImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSongDetailRow(_mockTitle, _mockArtist),
      ],
    );
  }

  Widget _buildManualMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Song Name',
          controller: _manualNameController,
          hint: 'Enter song title',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Artist Name',
          controller: _manualArtistController,
          hint: 'Enter artist name',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Album Name (Optional)',
          controller: _manualAlbumController,
          hint: 'Enter album name',
        ),
        const SizedBox(height: 20),
        _buildFilePickerField(
          label: 'Song Image',
          path: _pickedImagePath,
          onTap: _pickImage,
          icon: Icons.image_outlined,
          hint: 'Select cover image',
        ),
        const SizedBox(height: 20),
        _buildFilePickerField(
          label: 'Audio File',
          path: _pickedAudioPath,
          onTap: _pickAudio,
          icon: Icons.audiotrack_outlined,
          hint: 'Select audio file',
        ),
      ],
    );
  }

  Widget _buildFilePickerField({
    required String label,
    required String? path,
    required VoidCallback onTap,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: path != null
                    ? AppTheme.primaryColor
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    path != null
                        ? path.split(Platform.isWindows ? '\\' : '/').last
                        : hint,
                    style: TextStyle(
                      color: path != null ? Colors.white : Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (path != null)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedAudioPath = result.files.single.path;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  void _onAddSong() {
    final song = _isManualMode
        ? SongModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            songName: _manualNameController.text.isNotEmpty
                ? _manualNameController.text
                : "Manual Song",
            artistName: _manualArtistController.text.isNotEmpty
                ? _manualArtistController.text
                : "Manual Artist",
            albumName: _manualAlbumController.text.isNotEmpty
                ? _manualAlbumController.text
                : null,
            songImage: _pickedImagePath ?? _mockImage,
            audioFile:
                _pickedAudioPath ??
                "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            dateAdded: DateTime.now(),
            isManual: true,
          )
        : SongModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            songName: _mockTitle,
            artistName: _mockArtist,
            albumName: _linkAlbumController.text.isNotEmpty
                ? _linkAlbumController.text
                : _mockAlbum,
            songImage: _mockImage,
            audioFile: _linkController.text.isNotEmpty
                ? _linkController.text
                : "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            dateAdded: DateTime.now(),
            isManual: false,
          );

    context.read<SongBloc>().add(AddSong(song));
  }

  Widget _buildSongDetailRow(String leftText, String rightText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leftText,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          rightText,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _linkAlbumController.dispose();
    _manualNameController.dispose();
    _manualArtistController.dispose();
    _manualAlbumController.dispose();
    super.dispose();
  }
}
