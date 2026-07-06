import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/presentation/viewmodel/auth_viewmodel.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';

import 'login_page.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String? deepLinkToken;

  const ResetPasswordPage({super.key, required this.email, this.deepLinkToken});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    if (widget.deepLinkToken != null) {
      _tokenCtrl.text = widget.deepLinkToken!;
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref
          .read(authViewModelProvider.notifier)
          .resetPassword(
            token: _tokenCtrl.text.trim(),
            newPassword: _newPassCtrl.text.trim(),
            confirmPassword: _confirmCtrl.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Password reset failed.',
        );
      }
      if (next.status == AuthStatus.passwordResetSuccess) {
        SnackbarUtils.showSuccess(
          context,
          'Password reset successfully! Please sign in.',
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    });

    final isLoading =
        ref.watch(authViewModelProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Brand title (top-left, teal)
                const Text(
                  'YarnCraft Nepal',
                  style: TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 36),

                // Title
                const Text(
                  'Reset Password.',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Start your textile journey.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),

                const SizedBox(height: 36),

                // OTP / Token (only show if no deep-link token)
                if (widget.deepLinkToken == null) ...[
                  const _FieldLabel('Reset Code'),
                  const SizedBox(height: 8),
                  _PassField(
                    controller: _tokenCtrl,
                    hint: 'Enter OTP from email/SMS',
                    obscure: false,
                    keyboardType: TextInputType.number,
                    prefixIconData: Icons.tag_outlined,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter the reset code.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                ],

                // Password
                const _FieldLabel('Password'),
                const SizedBox(height: 8),
                _PassField(
                  controller: _newPassCtrl,
                  hint: '••••••••',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  prefixIconData: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Enter your new password.';
                    }
                    if (v.length < 6) return 'Minimum 6 characters.';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password
                const _FieldLabel('Confirm Password'),
                const SizedBox(height: 8),
                _PassField(
                  controller: _confirmCtrl,
                  hint: '••••••••',
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  prefixIconData: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Confirm your password.';
                    }
                    if (v != _newPassCtrl.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Reset button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B6B61),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Go To Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (_) => false,
                    ),
                    child: const Text(
                      'Go To Login',
                      style: TextStyle(
                        color: Color(0xFF1B6B61),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
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
      color: Color(0xFF111827),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}

// Password-style field

class _PassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggle;
  final IconData prefixIconData;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _PassField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.prefixIconData,
    this.onToggle,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(prefixIconData, color: const Color(0xFF9CA3AF), size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon: onToggle != null
            ? IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B6B61), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
      ),
    );
  }
}
