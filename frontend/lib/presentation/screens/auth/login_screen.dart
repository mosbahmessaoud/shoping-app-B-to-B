import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

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
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 15))),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(_emailController.text, _passwordController.text);
      final userType = await _authService.getUserType();
      
      if (!mounted) return;
      
      if (userType == 'admin') {
        context.go('/admin/dashboard');
      } else if (userType == 'client') {
        context.go('/client/home');
      } else {
        throw Exception('Type d\'utilisateur invalide');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String title = 'Erreur de Connexion';
      String message = 'Une erreur est survenue.';

      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
        title = 'Serveur Inaccessible';
        message = 'Impossible de se connecter au serveur.\n\n'
            '• Vérifiez que le serveur est démarré\n'
            '• Vérifiez votre connexion internet\n'
            '• Vérifiez l\'adresse du serveur';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        title = 'Délai d\'attente dépassé';
        message = 'La connexion a pris trop de temps.\n\nVérifiez votre connexion internet.';
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        title = 'Authentification échouée';
        message = 'Email ou mot de passe incorrect.\n\nVeuillez vérifier vos identifiants.';
      } else if (e.response?.statusCode == 404) {
        title = 'Compte introuvable';
        message = 'Aucun compte n\'existe avec cet email.';
      } else if (e.response?.statusCode == 500) {
        title = 'Erreur Serveur';
        message = 'Le serveur a rencontré une erreur.\n\nVeuillez réessayer plus tard.';
      }

      _showError(title, message);
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    
    int step = 1; // 1=email, 2=otp, 3=password
    bool loading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Réinitialiser', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step 1: Email
                if (step == 1) ...[
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : () async {
                        if (emailCtrl.text.isEmpty || !emailCtrl.text.contains('@')) {
                          _showError('Email invalide', 'Veuillez entrer un email valide.');
                          return;
                        }
                        setState(() => loading = true);
                        try {
                          await _apiService.sendOTP({'email': emailCtrl.text, 'otp_type': 'password_reset'});
                          setState(() {
                            step = 2;
                            loading = false;
                          });
                          _showSuccess('Code envoyé à ${emailCtrl.text}');
                        } on DioException catch (e) {
                          setState(() => loading = false);
                          if (e.response?.statusCode == 404) {
                            _showError('Compte introuvable', 'Aucun compte avec cet email.');
                          } else if (e.type == DioExceptionType.connectionError) {
                            _showError('Erreur de connexion', 'Serveur inaccessible.');
                          } else {
                            _showError('Erreur', 'Impossible d\'envoyer le code.');
                          }
                        }
                      },
                      child: loading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Envoyer Code'),
                    ),
                  ),
                ],
                
                // Step 2: OTP
                if (step == 2) ...[
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                    decoration: const InputDecoration(
                      hintText: '● ● ● ● ● ●',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : () {
                        if (otpCtrl.text.length != 6) {
                          _showError('Code invalide', 'Le code doit contenir 6 chiffres.');
                          return;
                        }
                        setState(() {
                          step = 3;
                          loading = false;
                        });
                        _showSuccess('Code vérifié!');
                      },
                      child: const Text('Vérifier'),
                    ),
                  ),
                ],
                
                // Step 3: New Password
                if (step == 3) ...[
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : () async {
                        if (passCtrl.text.length < 6) {
                          _showError('Mot de passe trop court', 'Minimum 6 caractères.');
                          return;
                        }
                        if (passCtrl.text != confirmCtrl.text) {
                          _showError('Erreur', 'Les mots de passe ne correspondent pas.');
                          return;
                        }
                        setState(() => loading = true);
                        try {
                          await _apiService.resetPassword({
                            'email': emailCtrl.text,
                            'otp_code': otpCtrl.text,
                            'new_password': passCtrl.text,
                          });
                          Navigator.pop(ctx);
                          _showSuccess('Mot de passe réinitialisé avec succès!');
                        } on DioException catch (e) {
                          setState(() => loading = false);
                          if (e.response?.statusCode == 400) {
                            _showError('Code expiré', 'Le code OTP a expiré.');
                          } else {
                            _showError('Erreur', 'Échec de la réinitialisation.');
                          }
                        }
                      },
                      child: loading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Réinitialiser'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_hospital, size: 60, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('Medical Store', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Connexion', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 40),
                  
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  
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
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text('Mot de passe oublié?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}