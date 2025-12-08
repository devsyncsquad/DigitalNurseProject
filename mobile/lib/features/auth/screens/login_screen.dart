import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/widgets/modern_scaffold.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool _obscurePassword = true;
  bool _showTestCredentials = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    // Add phone number formatter
    _phoneController.addListener(_formatPhoneInput);
  }

  void _formatPhoneInput() {
    final text = _phoneController.text;
    if (text.isEmpty) return;
    
    // If text doesn't start with +92, format it
    if (!text.startsWith('+92')) {
      final formatted = _formatPhoneNumber(text);
      if (formatted != text) {
        _phoneController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final authProvider = context.read<AuthProvider>();
    // Check if biometric is available for any user
    final isAvailable = await authProvider.isBiometricLoginAvailableForAnyUser();
    if (mounted) {
      setState(() {
        _biometricAvailable = isAvailable;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_formatPhoneInput);
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Format phone number to include +92 prefix if not already present
  String _formatPhoneNumber(String phone) {
    // Remove any whitespace
    String cleaned = phone.trim().replaceAll(RegExp(r'\s+'), '');
    
    // If already starts with +92, return as is
    if (cleaned.startsWith('+92')) {
      return cleaned;
    }
    
    // If starts with 92 (without +), add +
    if (cleaned.startsWith('92')) {
      return '+$cleaned';
    }
    
    // If starts with 0, replace 0 with +92
    if (cleaned.startsWith('0')) {
      return '+92${cleaned.substring(1)}';
    }
    
    // Otherwise, add +92 prefix
    return '+92$cleaned';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    // Format phone number to include +92 prefix
    final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
    
    final success = await authProvider.login(
      formattedPhone,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        final currentUser = authProvider.currentUser;
        if (currentUser != null) {
          // Show biometric enable dialog if biometric is available and not already enabled
          final biometricAvailable = await authProvider.isBiometricLoginAvailable(currentUser.id);
          if (!biometricAvailable) {
            // Check if device supports biometric
            final biometricService = BiometricService();
            final deviceSupportsBiometric = await biometricService.isAvailable();
            if (deviceSupportsBiometric) {
              // Show prompt to enable biometric login
              await _showBiometricEnableDialog(currentUser.id);
            }
          }
        }
        context.go('/home');
      } else {
        _showErrorSnackBar(authProvider.error ?? 'Login failed');
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final authProvider = context.read<AuthProvider>();
    
    // Get list of users with biometric enabled
    final userIds = await authProvider.getUsersWithBiometricEnabled();
    
    if (userIds.isEmpty) {
      _showErrorSnackBar('No biometric login set up. Please login with your phone and password first, then you can enable biometric login for faster access.');
      return;
    }
    
    String? selectedUserId;
    
    // If multiple users, show selection dialog
    if (userIds.length > 1) {
      selectedUserId = await _showUserSelectionDialog(userIds);
      if (selectedUserId == null) {
        // User cancelled selection
        return;
      }
    } else {
      // Single user, use that userId
      selectedUserId = userIds.first;
    }
    
    // Proceed with biometric login for selected user
    final success = await authProvider.loginWithBiometrics(selectedUserId);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        final errorMessage = authProvider.error ?? 'Biometric authentication failed or cancelled';
        String userFriendlyMessage;
        
        if (errorMessage.contains('No saved credentials')) {
          userFriendlyMessage = 'No saved credentials found for this account.\n\nPlease login with phone and password first, then enable biometric login.';
        } else if (errorMessage.contains('not enabled')) {
          userFriendlyMessage = 'Biometric login is not enabled for this account.\n\nPlease login with phone and password and enable biometric login.';
        } else if (errorMessage.contains('cancelled')) {
          userFriendlyMessage = 'Biometric authentication was cancelled.\n\nPlease try again.';
        } else if (errorMessage.contains('Invalid saved credentials')) {
          userFriendlyMessage = 'Saved credentials are invalid.\n\nPlease login with phone and password again to update your biometric login.';
        } else {
          userFriendlyMessage = errorMessage;
        }
        
        _showErrorSnackBar(userFriendlyMessage);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    // Extract user-friendly error message
    String errorMessage = message;
    
    // Remove common prefixes
    if (errorMessage.contains('Unauthorized:')) {
      errorMessage = errorMessage.split('Unauthorized:').last.trim();
    }
    if (errorMessage.contains('Exception: ')) {
      errorMessage = errorMessage.replaceFirst('Exception: ', '');
    }
    
    // If message is empty or generic, use a default message
    if (errorMessage.isEmpty || errorMessage == 'Login failed') {
      errorMessage = 'Invalid phone number or password. Please try again.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: AppTheme.getErrorColor(context),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show dialog to prompt user to enable biometric login
  Future<void> _showBiometricEnableDialog(String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enable Biometric Login'),
          content: Text(
            'Would you like to enable biometric login for faster access to your account?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Maybe Later'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = context.read<AuthProvider>();
                final currentUser = authProvider.currentUser;
                if (currentUser != null) {
                  final success = await authProvider.saveCredentialsForBiometric(
                    userId: userId,
                    phone: _formatPhoneNumber(_phoneController.text.trim()),
                    password: _passwordController.text,
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Biometric login enabled successfully')),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: ModernSurfaceTheme.primaryTeal,
              ),
              child: Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to select which user to login with (for multi-user scenarios)
  Future<String?> _showUserSelectionDialog(List<String> userIds) async {
    final secureStorage = SecureStorageService();
    
    // Get phone numbers for each user
    final List<Map<String, String>> users = [];
    for (final userId in userIds) {
      final phone = await secureStorage.getSavedPhone(userId);
      if (phone != null) {
        users.add({'userId': userId, 'phone': phone});
      }
    }
    
    if (users.isEmpty) {
      return null;
    }
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Account'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['phone'] ?? 'Unknown'),
                  subtitle: Text('User ID: ${user['userId']}'),
                  onTap: () => Navigator.of(context).pop(user['userId']),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return ModernScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: ModernSurfaceTheme.screenPadding(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                
                // Hero section with logo/title
                Container(
                  decoration: ModernSurfaceTheme.heroDecoration(context),
                  padding: ModernSurfaceTheme.heroPadding(),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Logo/Icon
                      Icon(
                        FIcons.heartPulse,
                        size: 80.r,
                        color: Colors.white,
                      ),
                      SizedBox(height: ModernSurfaceTheme.heroSpacing()),

                      // Title
                      Text(
                        'app.name'.tr(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'auth.login.welcomeBack'.tr(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Form container with glassmorphic card
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context, highlighted: true),
                  padding: ModernSurfaceTheme.cardPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Phone field
                      FTextField(
                        controller: _phoneController,
                        label: Text('auth.login.phone'.tr()),
                        hint: 'Enter phone number (e.g., 03001234567)',
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 20.h),

                      // Password field
                      FTextField(
                        controller: _passwordController,
                        label: Text('auth.login.password'.tr()),
                        hint: 'auth.login.passwordHint'.tr(),
                        obscureText: _obscurePassword,
                      ),
                      SizedBox(height: 28.h),

                      // Login button with modern pill style
                      Container(
                        decoration: ModernSurfaceTheme.pillButton(
                          context,
                          AppTheme.appleGreen,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: authProvider.isLoading ? null : _handleLogin,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              alignment: Alignment.center,
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'auth.login.loginButton'.tr(),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Biometric authentication button
                if (_biometricAvailable) ...[
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'or',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ModernSurfaceTheme.primaryTeal,
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: authProvider.isLoading ? null : _handleBiometricLogin,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(16.w),
                                child: Icon(
                                  Icons.fingerprint,
                                  size: 32.r,
                                  color: ModernSurfaceTheme.primaryTeal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Use Biometric Login',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Test credentials section
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context),
                  padding: ModernSurfaceTheme.cardPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showTestCredentials = !_showTestCredentials;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FIcons.info,
                                  size: 20.r,
                                  color: ModernSurfaceTheme.accentBlue,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Test Credentials',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _showTestCredentials ? Icons.expand_less : Icons.expand_more,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      if (_showTestCredentials) ...[
                        SizedBox(height: 16.h),
                        Divider(),
                        SizedBox(height: 12.h),
                        _buildTestCredential('Patient User', '+923001234567', 'password123'),
                        SizedBox(height: 12.h),
                        _buildTestCredential('Caregiver User', '+923007654321', 'password123'),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            _phoneController.text = '+923001234567';
                            _passwordController.text = 'password123';
                            setState(() {
                              _showTestCredentials = false;
                            });
                          },
                          child: Text(
                            'Use Patient Credentials',
                            style: TextStyle(
                              color: ModernSurfaceTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () {
                            _phoneController.text = '+923007654321';
                            _passwordController.text = 'password123';
                            setState(() {
                              _showTestCredentials = false;
                            });
                          },
                          child: Text(
                            'Use Caregiver Credentials',
                            style: TextStyle(
                              color: ModernSurfaceTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'auth.login.noAccount'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      ),
                      child: Text(
                        'auth.login.registerLink'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: ModernSurfaceTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCredential(String label, String phone, String password) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Phone: $phone',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Password: $password',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
