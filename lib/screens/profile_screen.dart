import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forum_application_flutter/models/profile_models.dart';
import 'package:forum_application_flutter/services/authentication_services.dart';
import 'package:forum_application_flutter/services/profile_services.dart';
import 'package:forum_application_flutter/services/storage_services.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final Future<ProfileModel?> _profileFuture;
  late String _initialUsername;
  late String _initialEmail;
  String? _avatarPath;
  XFile? _pendingAvatar;
  Uint8List? _pendingAvatarBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthenticationService().currentUser;
    _initialUsername = user?.userMetadata?['username'] as String? ?? '';
    _initialEmail = user?.email ?? '';
    _usernameController.text = _initialUsername;
    _emailController.text = _initialEmail;
    _profileFuture = _loadProfile();
    _usernameController.addListener(_refresh);
    _emailController.addListener(_refresh);
    _passwordController.addListener(_refresh);
  }

  Future<ProfileModel?> _loadProfile() async {
    final profile = await _profileService.getMyProfile();
    if (profile != null && mounted) {
      _initialUsername = profile.username;
      _usernameController.text = profile.username;
      _avatarPath = profile.avatarPath;
    }
    return profile;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _usernameController.text.trim() != _initialUsername ||
        _emailController.text.trim() != _initialEmail ||
        _passwordController.text.isNotEmpty ||
        _pendingAvatar != null;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.single;
    if (file.bytes == null) return;

    setState(() {
      _pendingAvatar = XFile.fromData(
        file.bytes!,
        name: file.name,
        path: file.name,
      );
      _pendingAvatarBytes = file.bytes;
    });
  }
  Future<void> _saveChanges() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = AuthenticationService().currentUser;
      if (user == null) throw Exception('No authenticated user.');

      final avatarPath = _pendingAvatar == null
          ? null
          : await _storageService.uploadAvatar(
              image: _pendingAvatar!,
              userId: user.id,
            );
      await _profileService.updateProfile(
        username: username,
        avatarPath: avatarPath,
      );

      if (email != _initialEmail || password.isNotEmpty) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            email: email != _initialEmail ? email : null,
            password: password.isNotEmpty ? password : null,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _initialUsername = username;
        _initialEmail = email;
        _avatarPath = avatarPath ?? _avatarPath;
        _pendingAvatar = null;
        _pendingAvatarBytes = null;
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile changes saved.')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: GridBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Material(
                  color: colors.surface,
                  shape: BeveledRectangleBorder(
                    side: BorderSide(color: colors.outline),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(34),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                    child: FutureBuilder<ProfileModel?>(
                      future: _profileFuture,
                      builder: (context, _) {
                        final username = _usernameController.text.isEmpty
                            ? 'U'
                            : _usernameController.text;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => Navigator.of(context).maybePop(),
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: Text(
                                  'BACK',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.primaryContainer,
                                    border: Border.all(
                                      color: colors.primary,
                                      width: 2,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _pendingAvatarBytes != null
                                      ? Image.memory(
                                          _pendingAvatarBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : _avatarPath != null
                                      ? Image.network(
                                          _storageService.getAvatarUrl(
                                            _avatarPath!,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Text(
                                              username.substring(0, 1).toUpperCase(),
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            username.substring(0, 1).toUpperCase(),
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 38,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: IconButton.filled(
                                    onPressed: _isSaving ? null : _pickAvatar,
                                    icon: const Icon(Icons.edit, size: 17),
                                    tooltip: 'Choose avatar',
                                    style: IconButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ACCOUNT PROFILE',
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Edit your account details',
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _accountField(
                              colors: colors,
                              label: 'USERNAME',
                              controller: _usernameController,
                              icon: Icons.alternate_email,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _accountField(
                              colors: colors,
                              label: 'EMAIL',
                              controller: _emailController,
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            _accountField(
                              colors: colors,
                              label: 'NEW PASSWORD',
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              hintText: 'Leave blank to keep current password',
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (_hasChanges && !_isSaving) _saveChanges();
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: FilledButton.icon(
                                onPressed: _hasChanges && !_isSaving
                                    ? _saveChanges
                                    : null,
                                icon: _isSaving
                                    ? SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined, size: 18),
                                label: Text(
                                  _isSaving ? 'SAVING...' : 'SAVE CHANGES',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  disabledBackgroundColor: colors.surfaceContainer,
                                  disabledForegroundColor: colors.onSurfaceVariant,
                                  shape: BeveledRectangleBorder(
                                    side: BorderSide(color: colors.outline),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountField({
    required ColorScheme colors,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    String? hintText,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: colors.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          cursorColor: colors.primary,
          style: GoogleFonts.jetBrainsMono(color: colors.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.jetBrainsMono(
              color: colors.onSurfaceVariant,
              fontSize: 11,
            ),
            prefixIcon: Icon(icon, color: colors.primary, size: 19),
            filled: true,
            fillColor: colors.surfaceContainer,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}