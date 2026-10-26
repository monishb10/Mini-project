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
  bool _isRegisterMode = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login form controllers
  final _loginEmailController =
      TextEditingController(text: 'admin@college.edu');
  final _loginPasswordController =
      TextEditingController(text: 'password123');
  bool _obscureLoginPassword = true;

  // Register form controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  final _regStudentIdController = TextEditingController();
  String _regRole = 'student'; // 'student' or 'faculty' ONLY (never 'admin')
  String _regDepartment = 'Computer Science & Engineering';
  bool _obscureRegPassword = true;

  static const List<String> _departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Electrical & Electronics',
    'Mechanical Engineering',
    'Civil Engineering',
    'Artificial Intelligence & Data Science',
  ];

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _regStudentIdController.dispose();
    super.dispose();
  }

  void _selectDemoAccount(String role) {
    setState(() {
      _isRegisterMode = false;
      if (role == 'admin') {
        _loginEmailController.text = 'admin@college.edu';
        _loginPasswordController.text = 'password123';
      } else if (role == 'faculty') {
        _loginEmailController.text = 'faculty@college.edu';
        _loginPasswordController.text = 'password123';
      } else {
        _loginEmailController.text = 'student@college.edu';
        _loginPasswordController.text = 'password123';
      }
    });

    final authController = context.read<AuthController>();
    authController.clearMessages();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.signIn(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text.trim(),
    );

    if (success && mounted) {
      if (authController.isAdmin) {
        context.go('/admin/dashboard');
      } else if (authController.isFaculty) {
        context.go('/faculty/dashboard');
      } else {
        context.go('/student/dashboard');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    if (_regPasswordController.text.trim() !=
        _regConfirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match. Please verify.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.signUp(
      email: _regEmailController.text.trim(),
      password: _regPasswordController.text.trim(),
      name: _regNameController.text.trim(),
      role: _regRole,
      department: _regDepartment,
      studentId:
          _regRole == 'student' ? _regStudentIdController.text.trim() : null,
    );

    if (success && mounted) {
      if (authController.isStudent) {
        context.go('/student/dashboard');
      } else if (authController.isFaculty) {
        context.go('/faculty/dashboard');
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _loginEmailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Account Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your institutional email address and we will dispatch a secure password reset link:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Institutional Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authController = context.read<AuthController>();
              Navigator.pop(ctx);
              await authController.sendPasswordReset(emailCtrl.text.trim());
              if (mounted && authController.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authController.successMessage!),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showAdminSetupDialog() {
    final nameCtrl = TextEditingController(text: 'Institutional Root Admin');
    final emailCtrl = TextEditingController(text: 'superadmin@college.edu');
    final passCtrl = TextEditingController(text: 'Admin@2026!');
    final tokenCtrl =
        TextEditingController(text: 'SAPM_INITIAL_ADMIN_TOKEN_2026');
    final deptCtrl = TextEditingController(text: 'Office of the Principal');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bootstrap Root Admin',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This secure bootstrap procedure is reserved for initializing the first system administrator. '
                    'It requires verification of the preconfigured administrative setup token.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    validator: (v) => Validators.required(v, 'Name is required'),
                    decoration: const InputDecoration(
                      labelText: 'Admin Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: 'Admin Institutional Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    validator: (v) => Validators.minLength(
                      v,
                      6,
                      'Password must be at least 6 characters',
                    ),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Admin Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: deptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Department / Office',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tokenCtrl,
                    validator: (v) =>
                        Validators.required(v, 'Setup token is required'),
                    decoration: const InputDecoration(
                      labelText: 'Administrative Setup Token',
                      hintText: 'SAPM_INITIAL_ADMIN_TOKEN_2026',
                      prefixIcon: Icon(Icons.key_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final authController = context.read<AuthController>();
              Navigator.pop(ctx);

              final success = await authController.createInitialAdmin(
                email: emailCtrl.text.trim(),
                password: passCtrl.text.trim(),
                name: nameCtrl.text.trim(),
                adminSetupToken: tokenCtrl.text.trim(),
                department: deptCtrl.text.trim(),
              );

              if (success && mounted) {
                context.go('/admin/dashboard');
              }
            },
            child: const Text('Initialize Admin Account'),
          ),
        ],
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Logo & Title
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
                      'Student Activity Participation Pattern Mining System',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Tab Selector: Sign In vs Register
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isRegisterMode = false);
                                authController.clearMessages();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isRegisterMode
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !_isRegisterMode
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                    fontWeight: !_isRegisterMode
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isRegisterMode = true);
                                authController.clearMessages();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isRegisterMode
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Register Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _isRegisterMode
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight),
                                    fontWeight: _isRegisterMode
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Banner
                    if (authController.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.error.withAlpha(80)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authController.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Success Banner
                    if (authController.successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.success.withAlpha(80)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authController.successMessage!,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Forms
                    if (!_isRegisterMode)
                      _buildSignInForm(context, theme, isDark, authController)
                    else
                      _buildRegisterForm(context, theme, isDark, authController),

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
                    const SizedBox(height: 16),

                    // Secure Initial Admin Link
                    Center(
                      child: TextButton.icon(
                        onPressed: _showAdminSetupDialog,
                        icon: const Icon(
                          Icons.security_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: const Text(
                          'System Bootstrap: Initialize First Admin',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AuthController authController,
  ) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Institutional Email
          Text(
            'Institutional Email',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginEmailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'name@college.edu',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
              ),
              InkWell(
                onTap: _showForgotPasswordDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginPasswordController,
            validator: (val) => Validators.minLength(
              val,
              6,
              'Password must be at least 6 characters',
            ),
            obscureText: _obscureLoginPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureLoginPassword = !_obscureLoginPassword,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign In Button
          ElevatedButton(
            onPressed: authController.isLoading ? null : _handleLogin,
            child: authController.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Sign In to Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AuthController authController,
  ) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role Selection: ONLY Student and Faculty allowed!
          Text(
            'Register As (Public Registration):',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Student'),
                    ],
                  ),
                  selected: _regRole == 'student',
                  onSelected: (selected) {
                    if (selected) setState(() => _regRole = 'student');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Faculty'),
                    ],
                  ),
                  selected: _regRole == 'faculty',
                  onSelected: (selected) {
                    if (selected) setState(() => _regRole = 'faculty');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Note: Administrator accounts can never be registered publicly.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 14),

          // Full Name
          Text(
            'Full Name',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regNameController,
            validator: (v) => Validators.required(v, 'Please enter your name'),
            decoration: const InputDecoration(
              hintText: 'e.g. Aarav Patel',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          // Institutional Email
          Text(
            'Institutional Email',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regEmailController,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'name@college.edu',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 14),

          // Department Dropdown
          Text(
            'Department',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _regDepartment,
            isExpanded: true,
            items: _departments
                .map((dept) => DropdownMenuItem(
                      value: dept,
                      child: Text(
                        dept,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _regDepartment = val);
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
            ),
          ),

          // Student Roll Number (only if Student role)
          if (_regRole == 'student') ...[
            const SizedBox(height: 14),
            Text(
              'Student Roll / Register Number',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regStudentIdController,
              validator: (v) => _regRole == 'student'
                  ? Validators.required(v, 'Roll number is required for students')
                  : null,
              decoration: const InputDecoration(
                hintText: 'e.g. 22CS104',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Password
          Text(
            'Password',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPasswordController,
            validator: (v) => Validators.minLength(
              v,
              6,
              'Password must be at least 6 characters',
            ),
            obscureText: _obscureRegPassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscureRegPassword = !_obscureRegPassword,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Confirm Password
          Text(
            'Confirm Password',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regConfirmPasswordController,
            validator: (v) => Validators.minLength(
              v,
              6,
              'Password must be at least 6 characters',
            ),
            obscureText: _obscureRegPassword,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 24),

          // Register Button
          ElevatedButton(
            onPressed: authController.isLoading ? null : _handleRegister,
            child: authController.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create ${_regRole.toUpperCase()} Account',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFillChip(String label, String role) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () => _selectDemoAccount(role),
    );
  }
}
