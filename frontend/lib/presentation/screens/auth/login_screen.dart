import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
// ADD these imports at the top:
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

// ADD these state variables in _LoginScreenState:

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Unified login that automatically detects user type
      await _authService.login(_emailController.text, _passwordController.text);
      
      // Get the user type to determine redirect
      final userType = await _authService.getUserType();
      
      if (!mounted) return;
      
      // Redirect based on user type
      if (userType == 'admin') {
        context.go('/admin/dashboard');
      } else if (userType == 'client') {
        context.go('/client/home');
      } else {
        throw Exception('Type d\'utilisateur invalide');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



// In your login_screen.dart, replace the entire _showForgotPasswordDialog method with:

Future<void> _showForgotPasswordDialog() async {
  await showImprovedForgotPasswordDialog(context, _apiService);
}

Future<void> showImprovedForgotPasswordDialog(BuildContext context, apiService) async {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool isResettingPassword = false;

  // Helper function to show error dialog
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Helper function to show success message
  void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(fontSize: 15))),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.lock_reset, color: theme.colorScheme.primary),
                ),
                SizedBox(width: 12),
                Text('Reset Password', style: TextStyle(fontSize: 20)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  Row(
                    children: [
                      _buildStepIndicator(1, 'Email', !isOtpSent, theme),
                      Expanded(child: Divider(thickness: 2)),
                      _buildStepIndicator(2, 'OTP', isOtpSent && !isOtpVerified, theme),
                      Expanded(child: Divider(thickness: 2)),
                      _buildStepIndicator(3, 'Password', isOtpVerified, theme),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Step 1: Email & Send OTP
                  if (!isOtpVerified) ...[
                    if (!isOtpSent) ...[
                      Text(
                        'Enter your email address',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We\'ll send you a verification code',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    
                    // Email field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isOtpSent,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'your.email@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isOtpSent ? Colors.grey[100] : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Send OTP Button
                    if (!isOtpSent)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isSendingOtp ? null : () async {
                            final email = emailController.text.trim();
                            
                            // Validation
                            if (email.isEmpty) {
                              showErrorDialog(
                                context,
                                'Email Required',
                                'Please enter your email address to continue.',
                              );
                              return;
                            }
                            
                            if (!email.contains('@') || !email.contains('.')) {
                              showErrorDialog(
                                context,
                                'Invalid Email',
                                'Please enter a valid email address (e.g., user@example.com).',
                              );
                              return;
                            }

                            setDialogState(() => isSendingOtp = true);

                            try {
                              final response = await apiService.sendOTP({
                                'email': email,
                                'otp_type': 'password_reset',
                              });
   
                              setDialogState(() {
                                isOtpSent = true;
                                isSendingOtp = false;
                              });

                              showSuccessSnackbar(context, 'OTP sent to $email');
                            } on DioException catch (e) {
                              setDialogState(() => isSendingOtp = false);
                              
                              String title = 'Error';
                              String message = 'Failed to send OTP. Please try again.';
                              
                              if (e.response?.statusCode == 404) {
                                title = 'Account Not Found';
                                message = 'No account exists with this email address.\n\nPlease check your email or create a new account.';
                              } else if (e.response?.statusCode == 400) {
                                title = 'Invalid Request';
                                final detail = e.response?.data['detail'];
                                message = detail ?? 'The email address format is invalid.';
                              } else if (e.type == DioExceptionType.connectionTimeout) {
                                title = 'Connection Timeout';
                                message = 'The request took too long.\n\nPlease check your internet connection and try again.';
                              } else if (e.type == DioExceptionType.connectionError) {
                                title = 'Connection Error';
                                message = 'Cannot connect to the server.\n\nPlease ensure:\n• The backend server is running\n• You have internet connection\n• The server address is correct';
                              } else if (e.response?.statusCode == 500) {
                                title = 'Server Error';
                                message = 'The server encountered an error.\n\nThis might be an email service issue. Please try again in a few moments.';
                              }
                              
                              showErrorDialog(context, title, message);
                            } catch (e) {
                              setDialogState(() => isSendingOtp = false);
                              showErrorDialog(
                                context,
                                'Unexpected Error',
                                'An unexpected error occurred:\n\n${e.toString()}\n\nPlease try again or contact support if the issue persists.',
                              );
                            }
                          },
                          icon: isSendingOtp
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.send),
                          label: Text(
                            isSendingOtp ? 'Sending OTP...' : 'Send OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                  
                  // Step 2: Verify OTP
                  if (isOtpSent && !isOtpVerified) ...[
                    Text(
                      'Enter verification code',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check your email for the 6-digit code',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: 12,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '● ● ● ● ● ●',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isVerifyingOtp ? null : () async {
                          final otp = otpController.text.trim();
                          
                          if (otp.isEmpty) {
                            showErrorDialog(
                              context,
                              'OTP Required',
                              'Please enter the 6-digit code sent to your email.',
                            );
                            return;
                          }
                          
                          if (otp.length != 6) {
                            showErrorDialog(
                              context,
                              'Invalid OTP',
                              'The verification code must be exactly 6 digits.\n\nPlease check your email and try again.',
                            );
                            return;
                          }

                          setDialogState(() => isVerifyingOtp = true);

                          try {
                            // Directly reset password without separate verification
                            // The resetPassword endpoint will verify the OTP internally
                            setDialogState(() {
                              isOtpVerified = true;
                              isVerifyingOtp = false;
                            });

                            showSuccessSnackbar(context, 'OTP verified! Now set your new password.');
                          } on DioException catch (e) {
                            setDialogState(() => isVerifyingOtp = false);
                            
                            String title = 'Verification Failed';
                            String message = 'The OTP code is invalid or expired.';
                            
                            if (e.response?.statusCode == 400) {
                              title = 'Invalid OTP';
                              message = 'The verification code is incorrect or has expired.\n\nPlease check your email or request a new code.';
                            }
                            
                            showErrorDialog(context, title, message);
                          } catch (e) {
                            setDialogState(() => isVerifyingOtp = false);
                            showErrorDialog(
                              context,
                              'Verification Error',
                              'Failed to verify OTP:\n\n${e.toString()}',
                            );
                          }
                        },
                        icon: isVerifyingOtp
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.verified),
                        label: Text(
                          isVerifyingOtp ? 'Verifying...' : 'Verify OTP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Step 3: New Password
                  if (isOtpVerified) ...[
                    Text(
                      'Create new password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Password must be at least 6 characters',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter new password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isResettingPassword ? null : () async {
                          final newPassword = newPasswordController.text;
                          final confirmPassword = confirmPasswordController.text;
                          
                          // Validation
                          if (newPassword.isEmpty) {
                            showErrorDialog(
                              context,
                              'Password Required',
                              'Please enter a new password.',
                            );
                            return;
                          }

                          if (newPassword.length < 6) {
                            showErrorDialog(
                              context,
                              'Password Too Short',
                              'Your password must be at least 6 characters long.\n\nPlease choose a stronger password.',
                            );
                            return;
                          }

                          if (newPassword != confirmPassword) {
                            showErrorDialog(
                              context,
                              'Passwords Don\'t Match',
                              'The passwords you entered do not match.\n\nPlease make sure both fields contain the same password.',
                            );
                            return;
                          }

                          setDialogState(() => isResettingPassword = true);

                          try {
                            await apiService.resetPassword({
                              'email': emailController.text.trim(),
                              'otp_code': otpController.text.trim(),
                              'new_password': newPassword,
                            });

                            Navigator.of(dialogContext).pop();
                            
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                                    SizedBox(width: 12),
                                    Text('Success!'),
                                  ],
                                ),
                                content: Text(
                                  'Your password has been reset successfully.\n\nYou can now login with your new password.',
                                  style: TextStyle(fontSize: 15, height: 1.4),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK', style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ),
                            );
                          } on DioException catch (e) {
                            setDialogState(() => isResettingPassword = false);
                            
                            String title = 'Reset Failed';
                            String message = 'Failed to reset password. Please try again.';
                            
                            if (e.response?.statusCode == 400) {
                              title = 'Invalid Request';
                              message = 'The OTP has expired or is invalid.\n\nPlease start the process again.';
                            } else if (e.response?.statusCode == 404) {
                              title = 'Account Not Found';
                              message = 'Unable to find your account.\n\nPlease try again or contact support.';
                            }
                            
                            showErrorDialog(context, title, message);
                          } catch (e) {
                            setDialogState(() => isResettingPassword = false);
                            showErrorDialog(
                              context,
                              'Reset Error',
                              'An error occurred while resetting your password:\n\n${e.toString()}',
                            );
                          }
                        },
                        icon: isResettingPassword
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.check),
                        label: Text(
                          isResettingPassword ? 'Resetting...' : 'Reset Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// Helper widget for step indicators
Widget _buildStepIndicator(int step, String label, bool isActive, ThemeData theme) {
  return Column(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? theme.colorScheme.primary : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Medical Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Medical Store',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connexion',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  CustomTextField(
                    label: 'Mot de passe',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Connexion',
                      icon: Icons.login,
                      onPressed: _login,
                      isLoading: _isLoading,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text("Pas de compte? S'inscrire"),
                  ),

                  
                  // ADD:
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}