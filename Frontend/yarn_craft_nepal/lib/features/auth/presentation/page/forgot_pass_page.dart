import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/presentation/viewmodel/auth_viewmodel.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputCtrl = TextEditingController();

  bool _sent = false;
  String _sentTo = '';

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref
          .read(authViewModelProvider.notifier)
          .forgotPassword(emailOrPhone: _inputCtrl.text.trim());
    }
  }

  // "Check your email" confirmation card
  Widget _sentConfirmation() {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5F3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFF1B6B61),
            size: 26,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check Your Email',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'If an account exists for\n$_sentTo,\nwe\'ve sent a password reset link.\nOpen it to set a new password.',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => setState(() => _sent = false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1B6B61),
              side: const BorderSide(color: Color(0xFF1B6B61), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Use a different email',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Return to Login',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Something went wrong.',
        );
      }
      if (next.status == AuthStatus.resetLinkSent) {
        setState(() {
          _sent = true;
          _sentTo = _inputCtrl.text.trim();
        });
      }
    });

    final isLoading =
        ref.watch(authViewModelProvider).status == AuthStatus.loading;

    return Scaffold(
      body: Container(
        // Gradient background matching Figma: teal-tinted top → warm cream bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFFD7E8E4), // cool teal tint
              Color(0xFFF0F5F4),
              Color(0xFFF5EDD8), // warm cream
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Brand title
                const Text(
                  'YarnCraft Nepal',
                  style: TextStyle(
                    color: Color(0xFF1B6B61),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 48),

                // White card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _sent
                      ? _sentConfirmation()
                      : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Key icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(
                            Icons.vpn_key_rounded,
                            color: Color(0xFF6B7280),
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Subtitle
                        const Text(
                          'Enter your email or phone to reset your\npassword.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        // Input field
                        TextFormField(
                          controller: _inputCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSend(),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your email or phone.'
                              : null,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email address or phone number',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Icon(
                                Icons.mail_outline,
                                color: Color(0xFF9CA3AF),
                                size: 18,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1B6B61),
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Send Reset Link button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSend,
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
                                        'Send Reset Link',
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

                        const SizedBox(height: 20),

                        // Return to Login
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Return to Login',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
