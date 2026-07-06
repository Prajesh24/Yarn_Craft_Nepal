import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactHelpPage extends ConsumerStatefulWidget {
  const ContactHelpPage({super.key});

  @override
  ConsumerState<ContactHelpPage> createState() => _ContactHelpPageState();
}

class _ContactHelpPageState extends ConsumerState<ContactHelpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSending = false;

  static const String _phone = '+977 1 234 5678';
  static const String _email = 'namaste@yarncraft.com';
  static const String _whatsapp = '9771234567';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$_whatsapp');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:$_phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:$_email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sendInquiry() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);

    // TODO: wire to your backend inquiry endpoint
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSending = false);

    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Message sent! We'll get back to you soon."),
        backgroundColor: Color(0xFF1B6B61),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    const Text(
                      'Need Help?',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "We're here to assist you with any questions\nabout our craft.",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // WhatsApp
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _openWhatsApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text(
                          'CHAT ON WHATSAPP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _ContactCard(
                      icon: Icons.phone_outlined,
                      label: 'Call Us',
                      value: _phone,
                      onTap: _callPhone,
                    ),

                    const SizedBox(height: 12),

                    _ContactCard(
                      icon: Icons.mail_outline,
                      label: 'Email Us',
                      value: _email,
                      onTap: _sendEmail,
                    ),

                    const SizedBox(height: 28),

                    // Inquiry form
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send an Inquiry',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 20),

                            const _FormLabel('Full Name'),
                            const SizedBox(height: 6),
                            _InquiryField(
                              controller: _nameCtrl,
                              hint: 'Your Name',
                              keyboardType: TextInputType.name,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter your name.'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            const _FormLabel('Email Address'),
                            const SizedBox(height: 6),
                            _InquiryField(
                              controller: _emailCtrl,
                              hint: 'your@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Enter your email.';
                                if (!v.contains('@'))
                                  return 'Enter a valid email.';
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            const _FormLabel('Message'),
                            const SizedBox(height: 6),
                            // maxLines:5 — _InquiryField auto-sets multiline keyboard
                            _InquiryField(
                              controller: _messageCtrl,
                              hint: 'How can we help you today?',
                              maxLines: 5,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter your message.'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isSending ? null : _sendInquiry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B6B61),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Send Message',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Contact card

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5F3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1B6B61), size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Form label

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

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

// Inquiry field

class _InquiryField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InquiryField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-switch to multiline when maxLines > 1 — prevents the assertion error
    final effectiveKeyboardType = maxLines > 1
        ? TextInputType.multiline
        : keyboardType;
    final effectiveInputAction = maxLines > 1
        ? TextInputAction.newline
        : TextInputAction.next;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: effectiveKeyboardType,
      textInputAction: effectiveInputAction,
      validator: validator,
      style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1B6B61), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFDC2626), fontSize: 11),
      ),
    );
  }
}
