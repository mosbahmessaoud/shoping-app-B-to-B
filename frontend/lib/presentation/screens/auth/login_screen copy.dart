// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/services/auth_service.dart';
// import '../../widgets/common/custom_text_field.dart';
// import '../../widgets/common/custom_button.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _authService = AuthService();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       // Unified login that automatically detects user type
//       await _authService.login(_emailController.text, _passwordController.text);
      
//       // Get the user type to determine redirect
//       final userType = await _authService.getUserType();
      
//       if (!mounted) return;
      
//       // Redirect based on user type
//       if (userType == 'admin') {
//         context.go('/admin/dashboard');
//       } else if (userType == 'client') {
//         context.go('/client/home');
//       } else {
//         throw Exception('Type d\'utilisateur invalide');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erreur: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Medical Icon
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primaryContainer,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.local_hospital,
//                       size: 60,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
                  
//                   Text(
//                     'Medical Store',
//                     style: theme.textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Connexion',
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
                  
//                   // Email Field
//                   CustomTextField(
//                     label: 'Email',
//                     controller: _emailController,
//                     prefixIcon: Icons.email_outlined,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (v) => v!.isEmpty ? 'Requis' : null,
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Password Field
//                   CustomTextField(
//                     label: 'Mot de passe',
//                     controller: _passwordController,
//                     prefixIcon: Icons.lock_outline,
//                     obscureText: _obscurePassword,
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                     validator: (v) => v!.isEmpty ? 'Requis' : null,
//                   ),
//                   const SizedBox(height: 32),
                  
//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: CustomButton(
//                       text: 'Connexion',
//                       icon: Icons.login,
//                       onPressed: _login,
//                       isLoading: _isLoading,
//                     ),
//                   ),
                  
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () => context.push('/register'),
//                     child: const Text("Pas de compte? S'inscrire"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }