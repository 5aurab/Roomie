import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/colors.dart';
import '../widgets/logo_mark.dart';
import '../widgets/otp_input.dart';
import '../widgets/resend_text.dart';
import '../widgets/verification_subtitle.dart';
import '../widgets/primary_button.dart';
import 'reset_password_screen.dart';

/// Controls what happens after a successful verification.
enum VerificationMode {
  /// Default: account creation / email confirmation.
  emailVerification,

  /// Forgot-password flow: navigate to ResetPasswordScreen.
  resetPassword,
}

class VerificationScreen extends StatefulWidget {
  final String email;

  /// Defaults to [VerificationMode.emailVerification].
  final VerificationMode mode;

  const VerificationScreen({
    super.key,
    required this.email,
    this.mode = VerificationMode.emailVerification,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _hasError = false;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      if (_resendCountdown <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  void _onResend() {
    if (!_canResend) return;
    // todo: call backend to resend code (use widget.mode to pick the right endpoint)
    _clearAll();
    _startResendTimer();
    _focusNodes[0].requestFocus();
  }

  void _onChanged(String value, int index) {
    setState(() => _hasError = false);

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _codeLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextIndex = digits.length < _codeLength
          ? digits.length
          : _codeLength - 1;
      _focusNodes[nextIndex].requestFocus();
      _tryAutoVerify();
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_isCodeComplete()) _tryAutoVerify();
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  bool _isCodeComplete() => _controllers.every((c) => c.text.isNotEmpty);

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _tryAutoVerify() {
    if (_isCodeComplete()) _handleVerify();
  }

  void _clearAll() {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _hasError = false);
  }

  Future<void> _handleVerify() async {
    if (!_isCodeComplete()) return;
    setState(() => _isLoading = true);

    // todo: send _fullCode + widget.mode to the appropriate backend endpoint
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    if (!mounted) return;

    // Simulate wrong code — remove when backend is connected
    final isValid = _fullCode != '000000';

    if (isValid) {
      _onSuccess();
    } else {
      setState(() => _hasError = true);
      _clearAll();
      _focusNodes[0].requestFocus();
    }
  }

  void _onSuccess() {
    switch (widget.mode) {
      case VerificationMode.resetPassword:
        // Replace this screen so back doesn't return to OTP
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: widget.email),
          ),
        );
      case VerificationMode.emailVerification:
        // todo: navigate to HomeSetupScreen
        break;
    }
  }

  // Title and subtitle copy differ per mode
  String get _title => switch (widget.mode) {
    VerificationMode.resetPassword => 'check your email',
    VerificationMode.emailVerification => 'check your email',
  };

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
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: RoomieColors.text,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              RoomieVerificationSubtitle(email: widget.email),
              const SizedBox(height: 40),
              RoomieOtpInput(
                controllers: _controllers,
                focusNodes: _focusNodes,
                hasError: _hasError,
                onChanged: _onChanged,
                onKeyEvent: _onKeyEvent,
              ),
              const SizedBox(height: 32),
              RoomiePrimaryButton(
                label: 'verify →',
                isLoading: _isLoading,
                onPressed: _isCodeComplete() ? _handleVerify : null,
              ),
              const SizedBox(height: 24),
              RoomieResendText(
                canResend: _canResend,
                countdown: _resendCountdown,
                onResend: _onResend,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
