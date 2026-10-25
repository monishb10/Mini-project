import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@college.edu');
  final _passwordController = TextEditingController(text: 'password123');
  String _selectedRole = 'admin';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectDemoAccount(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'admin') {
        _emailController.text = 'admin@college.edu';
      } else if (role == 'faculty') {
        _emailController.text = 'faculty@college.edu';
      } else {
        _emailController.text = 'student@college.edu';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      if (_selectedRole == 'admin') {
        context.go('/admin/dashboard');
      } else if (_selectedRole == 'faculty') {
        context.go('/faculty/dashboard');
      } else {
        context.go('/student/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<AuthController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF0B0F19)]
                : [const Color(0xFFEEF2FF), const Color(0xFFF8FAFC)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AppCard(
                padding: const EdgeInsets.all(36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(80),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppConstants.appName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'College Final-Year Project • Pattern Mining Portal',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Role Selection Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceSecondaryDark
                              : AppColors.surfaceSecondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildRoleTab(
                              'admin',
                              'Admin',
                              Icons.admin_panel_settings_outlined,
                            ),
                            _buildRoleTab(
                              'faculty',
                              'Faculty',
                              Icons.psychology_outlined,
                            ),
                            _buildRoleTab(
                              'student',
                              'Student',
                              Icons.school_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Field
                      Text(
                        'Institutional Email',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'name@college.edu',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      Text(
                        'Password',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        validator: (val) => Validators.minLength(
                          val,
                          6,
                          'Password must be at least 6 characters',
                        ),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),

                      if (authController.errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            authController.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: authController.isLoading
                            ? null
                            : _handleLogin,
                        child: authController.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text('Sign In as ${_selectedRole.toUpperCase()}'),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 14),

                      // Quick 1-Click Evaluation Credentials
                      Text(
                        'Evaluation Quick Logins (1-Click Demo):',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickFillChip('Admin (Dr. Sarah)', 'admin'),
                          _buildQuickFillChip(
                            'Faculty (Prof. Rajesh)',
                            'faculty',
                          ),
                          _buildQuickFillChip('Student (Aarav)', 'student'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String role, String title, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectDemoAccount(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFillChip(String label, String role) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => _selectDemoAccount(role),
      backgroundColor: _selectedRole == role
          ? AppColors.primaryContainer
          : null,
    );
  }
}
