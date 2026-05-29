import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../widgets/headers.dart';
import '../widgets/feature.dart';
import '../widgets/auth_tabs.dart';
import '../widgets/field_labels.dart';
import '../widgets/primary_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_buttons.dart';
import '../widgets/terms_text.dart';
import '../services/auth_services.dart';
import 'verification_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  late final PageController _pageController;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _isLoginLoading = false;
  String? _loginError;

  final _signupFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  DateTime? _selectedDob;
  bool _obscureSignupPassword = true;
  bool _isSignupLoading = false;
  String? _dobError;
  String? _signupError;

  bool _isSocialLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _switchTab(bool toLogin) {
    setState(() {
      _isLogin = toLogin;
      _dobError = null;
      _loginError = null;
      _signupError = null;
    });
    _pageController.animateToPage(
      toLogin ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    setState(() => _loginError = null);
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoginLoading = true);

    final error = await AuthService.login(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoginLoading = false);

    if (error != null) {
      setState(() => _loginError = error);
    } else {
      // todo: navigate to HomeScreen
    }
  }

  // ─── Signup ────────────────────────────────────────────────────────────────

  bool _isAgeValid(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age >= 16;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final maxDate = DateTime(now.year - 16, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
      helpText: 'select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RoomieColors.primary,
              onPrimary: RoomieColors.logoText,
              onSurface: RoomieColors.text,
              surface: RoomieColors.bg,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: RoomieColors.primary),
            ),
            dialogTheme:
                const DialogThemeData(backgroundColor: RoomieColors.bg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobError = null;
      });
    }
  }

  Future<void> _handleSignup() async {
    setState(() => _signupError = null);

    if (_selectedDob == null) {
      setState(() => _dobError = 'date of birth is required');
      return;
    }
    if (!_isAgeValid(_selectedDob!)) {
      setState(() => _dobError = 'you must be 18 or older to use roomie');
      return;
    }
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isSignupLoading = true);

    final error = await AuthService.signup(
      fullName: _fullNameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      email: _signupEmailController.text.trim(),
      password: _signupPasswordController.text,
      dob: _selectedDob!,
    );

    if (!mounted) return;
    setState(() => _isSignupLoading = false);

    if (error != null) {
      setState(() => _signupError = error);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            email: _signupEmailController.text.trim(),
            mode: VerificationMode.emailVerification,
          ),
        ),
      );
    }
  }

  // ─── Google ────────────────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSocialLoading = true);

    final error = await AuthService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isSocialLoading = false);

    if (error != null) {
      _showErrorSnackbar(error);
    } else {
      // todo: navigate to HomeScreen
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: RoomieColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatDob(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.year}';

  // ─── Bottom section (shared) ───────────────────────────────────────────────

  Widget _buildBottomSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const RoomieOrDivider(),
        const SizedBox(height: 16),
        _isSocialLoading
            ? const SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RoomieColors.primary,
                  ),
                ),
              )
            : RoomieSocialButtons(
                onGoogleTap: _handleGoogleSignIn,
              ),
        const SizedBox(height: 20),
        const RoomieTermsText(),
      ],
    );
  }

  // ─── Login form ────────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const RoomieFieldLabel('email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration: RoomieInputDecoration.of('you@email.com'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'email is required';
              if (!v.contains('@')) return 'enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const RoomieFieldLabel('password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration: RoomieInputDecoration.of('••••••••').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: RoomieColors.primaryMid,
                ),
                onPressed: () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'password is required';
              return null;
            },
          ),
          const SizedBox(height: 8),

          // ── Error banner ──
          if (_loginError != null) ...[
            const SizedBox(height: 4),
            _ErrorBanner(message: _loginError!),
            const SizedBox(height: 4),
          ],

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'forgot password?',
                style:
                    TextStyle(fontSize: 12, color: RoomieColors.primaryMid),
              ),
            ),
          ),
          const SizedBox(height: 20),

          RoomiePrimaryButton(
            label: 'log in →',
            isLoading: _isLoginLoading,
            onPressed: _handleLogin,
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  // ─── Signup form ───────────────────────────────────────────────────────────

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const RoomieFieldLabel('full name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration: RoomieInputDecoration.of('your full name'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'full name is required';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const RoomieFieldLabel('display name'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _displayNameController,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration: RoomieInputDecoration.of('what your roommates see'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'display name is required';
              }
              if (v.trim().length < 2) return 'must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const RoomieFieldLabel('date of birth'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDob,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _dobError != null
                      ? RoomieColors.error
                      : RoomieColors.border,
                  width: _dobError != null ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: _selectedDob != null
                        ? RoomieColors.primary
                        : RoomieColors.hint,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDob != null
                        ? _formatDob(_selectedDob!)
                        : 'dd / mm / yyyy',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDob != null
                          ? RoomieColors.text
                          : RoomieColors.hint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dobError != null) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _dobError!,
                style: const TextStyle(
                    fontSize: 11, color: RoomieColors.errorText),
              ),
            ),
          ],
          const SizedBox(height: 14),

          const RoomieFieldLabel('email'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration: RoomieInputDecoration.of('you@email.com'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'email is required';
              if (!v.contains('@')) return 'enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),

          const RoomieFieldLabel('password'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _signupPasswordController,
            obscureText: _obscureSignupPassword,
            style: const TextStyle(fontSize: 13, color: RoomieColors.text),
            decoration:
                RoomieInputDecoration.of('create a password').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignupPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: RoomieColors.primaryMid,
                ),
                onPressed: () => setState(
                    () => _obscureSignupPassword = !_obscureSignupPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'password is required';
              if (v.length < 8) return 'must be at least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // ── Error banner ──
          if (_signupError != null) ...[
            _ErrorBanner(message: _signupError!),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 12),
          RoomiePrimaryButton(
            label: 'create account →',
            isLoading: _isSignupLoading,
            onPressed: _handleSignup,
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoomieColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const RoomieHeader(),
                  const SizedBox(height: 28),
                  const RoomieFeaturePills(),
                  const SizedBox(height: 28),
                  const Divider(color: RoomieColors.border, thickness: 0.5),
                  const SizedBox(height: 24),
                  RoomieAuthTabs(
                    activeTab: _isLogin ? 'login' : 'signup',
                    onInactiveTap: () => _switchTab(!_isLogin),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildLoginForm(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSignupForm(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared error banner widget ──────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RoomieColors.error.withValues(alpha: 0.08),
        border: Border.all(color: RoomieColors.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 14, color: RoomieColors.errorText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  fontSize: 12, color: RoomieColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}