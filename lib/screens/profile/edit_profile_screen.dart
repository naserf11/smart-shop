import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  String? _existingImageUrl;
  Uint8List? _pickedImageBytes;
  String? _pickedImageExt;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<void> _loadProfile() async {
    final userId = _userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'You are not signed in.';
      });
      return;
    }

    try {
      // Query customers table using firebase_uid
      final response = await _supabase
          .from('customers')
          .select()
          .eq('firebase_uid', userId)
          .maybeSingle();

      if (!mounted) return;

      if (response == null) {
        // No row yet — pre-fill email from auth
        _emailController.text = _supabase.auth.currentUser?.email ?? '';
      } else {
        _fullNameController.text = response['full_name'] ?? '';
        // Phone is optional — only fill if not null
        _phoneController.text = response['phone_number'] ?? '';
        _emailController.text =
            response['email'] ?? _supabase.auth.currentUser?.email ?? '';
        _existingImageUrl = response['profile_image_url'];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Failed to load profile: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      
      // On web, picked.path is a blob URL so we can't extract extension from it.
      // Instead, use the file name which is always reliable on all platforms.
      String ext = 'jpg'; // safe default
      final fileName = picked.name; // e.g. "photo.png"
      if (fileName.contains('.')) {
        ext = fileName.split('.').last.toLowerCase();
      }

      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageExt = ext;
      });
    } catch (e) {
      _showSnack('Could not open image picker: $e', isError: true);
    }
  }

  Future<String?> _uploadAvatarIfNeeded(String userId) async {
    if (_pickedImageBytes == null) return _existingImageUrl;

    final ext = (_pickedImageExt == null || _pickedImageExt!.isEmpty)
        ? 'jpg'
        : _pickedImageExt!;
    final path = '$userId/avatar.$ext';

    await _supabase.storage
        .from('avatars')
        .uploadBinary(
          path,
          _pickedImageBytes!,
          fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
        );

    final publicUrl =
        _supabase.storage.from('avatars').getPublicUrl(path);
    // Cache-bust so the new image shows immediately
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }
    return null;
  }

  // Phone is now OPTIONAL — only validate format if something is entered
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional — skip validation
    }
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (e.g. +60123456789)';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _userId;
    if (userId == null) {
      _showSnack('You are not signed in.', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      // Upload image first
      final imageUrl = await _uploadAvatarIfNeeded(userId);

      final payload = <String, dynamic>{
        'firebase_uid': userId,
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        payload['phone_number'] = phone;
      }

      if (imageUrl != null) {
        payload['profile_image_url'] = imageUrl;
      }

      await _supabase
          .from('customers')
          .upsert(payload, onConflict: 'firebase_uid');

      if (!mounted) return;
      setState(() {
        _existingImageUrl = imageUrl;
        _pickedImageBytes = null;
      });

      _showSnack('Profile updated successfully');

    } on StorageException catch (e) {
      // Image upload failed
      _showSnack('Image upload failed: ${e.message}', isError: true);
    } on PostgrestException catch (e) {
      // Database save failed
      _showSnack('Database error: ${e.message} (code: ${e.code})', isError: true);
    } catch (e) {
      _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // ── Avatar picker ──────────────────────────────────
                        _buildAvatarPicker(),

                        const SizedBox(height: 30),

                        // ── Full Name ──────────────────────────────────────
                        TextFormField(
                          controller: _fullNameController,
                          enabled: !_isSaving,
                          validator: _validateFullName,
                          decoration: _fieldDecoration(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ── Phone (optional) ───────────────────────────────
                        TextFormField(
                          controller: _phoneController,
                          enabled: !_isSaving,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          decoration: _fieldDecoration(
                            label: 'Phone Number (optional)',
                            icon: Icons.phone_outlined,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ── Email (read-only) ──────────────────────────────
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: _fieldDecoration(
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Save button ────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 65,
          backgroundColor: const Color(0xffeeeeee),
          backgroundImage: _pickedImageBytes != null
              ? MemoryImage(_pickedImageBytes!)
              : (_existingImageUrl != null
                    ? NetworkImage(_existingImageUrl!) as ImageProvider
                    : null),
          child: (_pickedImageBytes == null && _existingImageUrl == null)
              ? const Icon(Icons.person, size: 70, color: Colors.grey)
              : null,
        ),
        GestureDetector(
          onTap: _isSaving ? null : _pickImage,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xfff4f4f4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon),
      labelText: label,
    );
  }
}