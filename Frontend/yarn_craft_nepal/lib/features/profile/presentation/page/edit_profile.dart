import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'saved_changes.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String _gender = 'Prefer not to say';
  bool _isSaving = false;

  XFile? _pickedImage; // newly selected (not yet saved) avatar
  String? _existingImageUrl; // avatar already stored on the backend

  final List<String> _genders = const [
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).authEntity;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _existingImageUrl = user?.imageUrl;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF1B6B61)),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF1B6B61)),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  /// Resolves which image (if any) to show in the avatar: a freshly picked
  /// local file takes priority, then the existing stored network image.
  ImageProvider? _avatarImage() {
    if (_pickedImage != null) return FileImage(File(_pickedImage!.path));
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return NetworkImage(_existingImageUrl!);
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    await ref.read(authViewModelProvider.notifier).updateAuthEntity(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          imagePath: _pickedImage?.path,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChangesSavedPage()),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B6B61),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'YarnCraft Nepal',
                        style: TextStyle(
                          color: Color(0xFF1B6B61),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Update your personal information to ensure a\nseamless shopping experience.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Avatar with edit badge (tap to change photo)
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 44,
                                backgroundColor: const Color(0xFFE8F5F3),
                                backgroundImage: _avatarImage(),
                                child: _avatarImage() == null
                                    ? Text(
                                        _nameCtrl.text.trim().isNotEmpty
                                            ? _nameCtrl.text
                                                  .trim()[0]
                                                  .toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Color(0xFF1B6B61),
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B6B61),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Full Name
                      const _FieldLabel('Full Name'),
                      const SizedBox(height: 6),
                      _ProfileField(
                        controller: _nameCtrl,
                        hint: 'Your name',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter your name.'
                            : null,
                      ),

                      const SizedBox(height: 18),

                      // Email (editable)
                      _FieldLabelWithBadge(
                        label: 'Email Address',
                        badge: '',
                      ),
                      const SizedBox(height: 6),
                      _ProfileField(
                        controller: _emailCtrl,
                        hint: 'your@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Email is required.';
                          final emailRegex =
                              RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // Phone
                      const _FieldLabel('Phone Number'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '+977',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileField(
                              controller: _phoneCtrl,
                              hint: 'Phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (v) {
                                final digits =
                                    (v ?? '').replaceAll(RegExp(r'\D'), '');
                                if (digits.isEmpty) return null; // optional
                                if (digits.length != 10) {
                                  return 'Phone number must be exactly 10 digits.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Date of Birth
                      const _FieldLabel('Date of Birth'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: _ProfileField(
                            controller: _dobCtrl,
                            hint: 'MM/DD/YYYY',
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF9CA3AF),
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Gender
                      const _FieldLabel('Gender'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _gender,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF6B7280),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                            ),
                            items: _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _gender = v ?? _gender),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6B7280),
                                side: const BorderSide(
                                  color: Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B6B61),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Field label

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF374151),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _FieldLabelWithBadge extends StatelessWidget {
  final String label, badge;
  const _FieldLabelWithBadge({required this.label, required this.badge});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const Spacer(),
      if (badge.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: Color(0xFF1B6B61),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}

// Profile text field

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _ProfileField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    inputFormatters: inputFormatters,
    style: const TextStyle(
      color: Color(0xFF111827),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      suffixIcon: suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: suffixIcon,
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF1B6B61),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFDC2626),
        fontSize: 11,
      ),
    ),
  );
}
