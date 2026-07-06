import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarn_craft_nepal/features/auth/presentation/viewmodel/auth_viewmodel.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../state/auth_state.dart';
import 'login_page.dart';
import 'account_created_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _agreedToTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() => _termsError = !_agreedToTerms);
    if (!_formKey.currentState!.validate() || !_agreedToTerms) return;
    FocusScope.of(context).unfocus();

    ref
        .read(authViewModelProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          confirmPassword: _passwordCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration failed.',
        );
      }
      if (next.status == AuthStatus.registered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountCreatedPage()),
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
                const SizedBox(height: 20),

                // Header: back + brand
                Row(
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
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),
                  ],
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Create Account.',
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

                const SizedBox(height: 32),

                // Full Name
                const _FieldLabel('Full Name'),
                const SizedBox(height: 8),
                _AuthField(
                  controller: _nameCtrl,
                  hint: 'Jane Doe',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter your full name.'
                      : null,
                ),

                const SizedBox(height: 20),

                // Email
                const _FieldLabel('Email'),
                const SizedBox(height: 8),
                _AuthField(
                  controller: _emailCtrl,
                  hint: 'jane@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter your email.';
                    }
                    if (!v.contains('@')) return 'Enter a valid email.';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Phone Number
                const _FieldLabel('Phone Number'),
                const SizedBox(height: 8),
                _AuthField(
                  controller: _phoneCtrl,
                  hint: '9800000000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.isEmpty) return 'Enter your phone number.';
                    if (digits.length != 10) {
                      return 'Phone number must be exactly 10 digits.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password
                const _FieldLabel('Password'),
                const SizedBox(height: 8),
                _AuthField(
                  controller: _passwordCtrl,
                  hint: '••••••••',
                  obscure: _obscurePass,
                  onToggleObscure: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password.';
                    if (v.length < 6) return 'Minimum 6 characters.';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Terms & Conditions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (v) => setState(() {
                              _agreedToTerms = v ?? false;
                              if (_agreedToTerms) _termsError = false;
                            }),
                            activeColor: const Color(0xFF1B6B61),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF1B6B61),
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF1B6B61),
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF1B6B61),
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFF1B6B61),
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 30),
                        child: Text(
                          'You must agree to continue.',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
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
                                'Create Account',
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

                // Already have account
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account?  '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF1B6B61),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
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

// Reusable field label

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

// Reusable auth text field

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.prefixIcon,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
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
