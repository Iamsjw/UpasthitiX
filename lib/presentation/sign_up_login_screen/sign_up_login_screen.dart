
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/demo_credentials_widget.dart';
import './widgets/particle_background_widget.dart';
import './widgets/role_selector_widget.dart';

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod AuthNotifier for production

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'student';
  String? _errorMessage;

  late AnimationController _entranceController;
  late AnimationController _logoController;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;
  late Animation<double> _logoScale;
  late Animation<double> _logoPulse;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _entranceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _logoPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        final response = await SupabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (response.user != null) {
          final profile = await SupabaseService.getUserProfile(
            response.user!.id,
          );
          if (profile != null && mounted) {
            _navigateByRole(profile.role);
          } else if (mounted) {
            setState(() => _errorMessage = 'Profile not found. Contact admin.');
          }
        }
      } else {
        final response = await SupabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          _selectedRole,
        );
        if (response.user != null && mounted) {
          _navigateByRole(_selectedRole);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message.contains('Invalid')
              ? 'Invalid credentials — use the demo accounts below to sign in'
              : e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Connection error. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateByRole(String role) {
    if (role == 'teacher') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.teacherSessionScreen,
        (_) => false,
      );
    } else if (role == 'student') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.studentAttendanceScreen,
        (_) => false,
      );
    } else {
      // Admin — for now goes to teacher screen as admin dashboard not in scope
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.teacherSessionScreen,
        (_) => false,
      );
    }
  }

  void _autofillCredentials(String email, String password, String role) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
      _selectedRole = role;
      _isLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // Particle background
            const ParticleBackgroundWidget(),
            // Gradient overlays
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      AppTheme.primary.withAlpha(31),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 0 : 24,
                    vertical: 24,
                  ),
                  child: AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _entranceFade,
                        child: SlideTransition(
                          position: _entranceSlide,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: isTablet ? 480 : double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogoSection(),
                          const SizedBox(height: 32),
                          _buildAuthCard(),
                          const SizedBox(height: 20),
                          DemoCredentialsWidget(
                            onAutofill: _autofillCredentials,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return ScaleTransition(
          scale: _logoScale,
          child: Transform.scale(scale: _logoPulse.value, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF22D3EE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(102),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'UpasthitiX',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Smart BLE Attendance System',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0x99FFFFFF),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return GlassCardWidget(
      borderRadius: 24,
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle Login / Sign Up
            _buildAuthToggle(),
            const SizedBox(height: 24),

            // Role selector (sign-up only)
            if (!_isLogin) ...[
              RoleSelectorWidget(
                selectedRole: _selectedRole,
                onRoleChanged: (role) => setState(() => _selectedRole = role),
              ),
              const SizedBox(height: 16),
              GlassFormFieldWidget(
                label: 'Full Name',
                hint: 'Your full name',
                controller: _nameController,
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0x66FFFFFF),
                  size: 20,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
            ],

            GlassFormFieldWidget(
              label: 'Email Address',
              hint: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0x66FFFFFF),
                size: 20,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            GlassFormFieldWidget(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0x66FFFFFF),
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0x66FFFFFF),
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 6) return 'Min 6 characters';
                return null;
              },
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1AEF4444),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33EF4444), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      ),
      child: Row(
        children: [_toggleTab('Sign In', true), _toggleTab('Sign Up', false)],
      ),
    );
  }

  Widget _toggleTab(String label, bool isLoginTab) {
    final isActive = _isLogin == isLoginTab;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withAlpha(217)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => setState(() {
            _isLogin = isLoginTab;
            _errorMessage = null;
          }),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0x66FFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5B50F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(102),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleAuth,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withAlpha(26),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isLogin ? 'Sign In' : 'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
