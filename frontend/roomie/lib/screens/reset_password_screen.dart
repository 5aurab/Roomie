import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../widgets/logo_mark.dart';
import '../widgets/field_labels.dart';
import '../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // todo: call backend with widget.email + _passwordController.text
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  void _goToLogin() {
    // Pop all the way back to AuthScreen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoomieColors.bg,
      appBar: AppBar(
        backgroundColor: RoomieColors.bg,
        elevation: 0,
        // No back button — user must use the action below
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _isSuccess ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const RoomieLogo(),
        const SizedBox(height: 28),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: RoomieColors.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose a new password for your account',
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
              const RoomieFieldLabel('new password'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 13, color: RoomieColors.text),
                decoration: RoomieInputDecoration.of('create a password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: RoomieColors.primaryMid,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'password is required';
                  if (v.length < 8) return 'must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const RoomieFieldLabel('confirm password'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: const TextStyle(fontSize: 13, color: RoomieColors.text),
                decoration: RoomieInputDecoration.of('repeat your password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: RoomieColors.primaryMid,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'please confirm your password';
                  if (v != _passwordController.text) {
                    return 'passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              RoomiePrimaryButton(
                label: 'save password →',
                isLoading: _isLoading,
                onPressed: _handleReset,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: RoomieColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: RoomieColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'password updated!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: RoomieColors.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'your password has been reset.\nyou can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: RoomieColors.primaryMid,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        RoomiePrimaryButton(
          label: 'back to login →',
          isLoading: false,
          onPressed: _goToLogin,
        ),
      ],
    );
  }
}