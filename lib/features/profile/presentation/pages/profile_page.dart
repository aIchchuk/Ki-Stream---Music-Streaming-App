import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/data/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTabIndex = 0; // 0 for Settings, 1 for Personal Info
  bool _isPasswordVisible = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  bool _isEditing = false;
  String? _initialEmail;
  String? _initialPassword;
  String? _initialUsername;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        context.read<AuthBloc>().add(UpdateProfilePhoto(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              UserModel? user;
              if (state is Authenticated) {
                user = state.user;
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Profile Picture (Clickable)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              image: DecorationImage(
                                image: _getProfileImage(user?.photoUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      user?.displayName ?? "Guest",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tab Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTabIndex == 0
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Settings",
                                      style: TextStyle(
                                        color: _selectedTabIndex == 0
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTabIndex = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedTabIndex == 1
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Personal Info",
                                      style: TextStyle(
                                        color: _selectedTabIndex == 1
                                            ? Colors.white
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tab Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _selectedTabIndex == 0
                            ? _buildSettingsTab()
                            : _buildPersonalInfo(user),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ImageProvider _getProfileImage(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http') || photoUrl.startsWith('https')) {
        return NetworkImage(photoUrl);
      } else if (File(photoUrl).existsSync()) {
        return FileImage(File(photoUrl));
      }
    }
    return const NetworkImage(
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-DXFpesytRtBxTDt3pmlwFLKZAPbUkQ_CDg&s",
    );
  }

  Widget _buildPersonalInfo(UserModel? user) {
    if (!_isEditing && user != null) {
      if (_emailController.text != user.email) {
        _emailController.text = user.email;
        _initialEmail = user.email;
      }
      if (_passwordController.text != (user.password ?? "")) {
        _passwordController.text = user.password ?? "";
        _initialPassword = user.password ?? "";
      }
      if (_usernameController.text != user.displayName) {
        _usernameController.text = user.displayName;
        _initialUsername = user.displayName;
      }
    }

    bool hasChanges =
        _usernameController.text != _initialUsername ||
        _emailController.text != _initialEmail ||
        _passwordController.text != _initialPassword;

    return Column(
      key: const ValueKey(1),
      children: [
        _buildEditableInfoTile(
          icon: Icons.person_outline,
          label: "Username",
          controller: _usernameController,
          onChanged: (val) => setState(() {}),
        ),
        _buildDivider(),
        _buildEditableInfoTile(
          icon: Icons.email_outlined,
          label: "Email",
          controller: _emailController,
          onChanged: (val) => setState(() {}),
        ),
        _buildDivider(),
        _buildEditableInfoTile(
          icon: Icons.lock_outline,
          label: "Password",
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          onChanged: (val) => setState(() {}),
          showEyeIcon: true,
          onEyePressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        const SizedBox(height: 30),
        if (hasChanges) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_usernameController.text != _initialUsername) {
                  context.read<AuthBloc>().add(
                    UpdateUsernameRequested(_usernameController.text),
                  );
                }
                if (_emailController.text != _initialEmail) {
                  context.read<AuthBloc>().add(
                    UpdateEmailRequested(_emailController.text),
                  );
                }
                if (_passwordController.text != _initialPassword) {
                  context.read<AuthBloc>().add(
                    UpdatePasswordRequested(_passwordController.text),
                  );
                }
                setState(() {
                  _initialUsername = _usernameController.text;
                  _initialEmail = _emailController.text;
                  _initialPassword = _passwordController.text;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("Save Changes"),
            ),
          ),
          const SizedBox(height: 15),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDeleteAccountConfirmation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
              ),
            ),
            child: const Text("Delete Account"),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    bool showEyeIcon = false,
    VoidCallback? onEyePressed,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: controller,
                  obscureText: obscureText,
                  onChanged: onChanged,
                  onTap: () => setState(() => _isEditing = true),
                  onSubmitted: (val) => setState(() => _isEditing = false),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showEyeIcon)
            GestureDetector(
              onTap: onEyePressed,
              child: Icon(
                !obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(DeleteAccountRequested());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      key: const ValueKey(0),
      children: [
        _buildInfoTile(
          icon: Icons.notifications_none,
          label: "Notifications",
          value: "Enabled",
        ),
        _buildDivider(),
        _buildInfoTile(
          icon: Icons.language,
          label: "Language",
          value: "English",
        ),
        const SizedBox(height: 0),
        // Admin Dashboard Link (Only if admin)
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String email = '';
            if (state is Authenticated) {
              email = state.user.email;
            }
            if (email == 'admin@gmail.com') {
              return Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: "Admin Dashboard",
                    value: "Manage Content",
                    onTap: () => context.push('/admin-dashboard'),
                  ),
                  _buildDivider(),
                  const SizedBox(height: 30),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Logout Button moved here
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.2),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text("Log Out"),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool showEyeIcon = false,
    VoidCallback? onEyePressed,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (showEyeIcon)
              GestureDetector(
                onTap: onEyePressed,
                child: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);
  }
}
