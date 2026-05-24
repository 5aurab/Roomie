import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../widgets/logo_mark.dart';
import '../widgets/field_labels.dart';
import '../widgets/primary_button.dart';
import 'verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // todo: call backend to send reset code to _emailController.text
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          email: _emailController.text.trim(),
          mode: VerificationMode.resetPassword,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoomieColors.bg,
      appBar: AppBar(
        backgroundColor: RoomieColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: RoomieColors.text,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const RoomieLogo(),
              const SizedBox(height: 28),
              const Text(
                'forgot password?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: RoomieColors.text,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "enter your email and we'll send\na reset code your way",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: RoomieColors.primaryMid,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RoomieFieldLabel('email'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: RoomieColors.text,
                      ),
                      decoration: RoomieInputDecoration.of('you@email.com'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'email is required';
                        if (!v.contains('@')) return 'enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    RoomiePrimaryButton(
                      label: 'send code →',
                      isLoading: _isLoading,
                      onPressed: _handleSend,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}