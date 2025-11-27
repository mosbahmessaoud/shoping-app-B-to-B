// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:store_app/core/services/auth_service.dart';
// import '../../../core/services/api_service.dart';
// import '../../../core/services/storage_service.dart';
// import '../../../core/services/theme_service.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _adresse = TextEditingController();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _apiService = ApiService();
//   final _apiAuth = AuthService();
//   final _storage = StorageService();
//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   String? _selectedCity;

//   // All 58 Algerian Wilayas
//   final List<String> _algerianCities = [
//     '01 - Adrar',
//     '02 - Chlef',
//     '03 - Laghouat',
//     '04 - Oum El Bouaghi',
//     '05 - Batna',
//     '06 - Béjaïa',
//     '07 - Biskra',
//     '08 - Béchar',
//     '09 - Blida',
//     '10 - Bouira',
//     '11 - Tamanrasset',
//     '12 - Tébessa',
//     '13 - Tlemcen',
//     '14 - Tiaret',
//     '15 - Tizi Ouzou',
//     '16 - Alger',
//     '17 - Djelfa',
//     '18 - Jijel',
//     '19 - Sétif',
//     '20 - Saïda',
//     '21 - Skikda',
//     '22 - Sidi Bel Abbès',
//     '23 - Annaba',
//     '24 - Guelma',
//     '25 - Constantine',
//     '26 - Médéa',
//     '27 - Mostaganem',
//     '28 - M\'Sila',
//     '29 - Mascara',
//     '30 - Ouargla',
//     '31 - Oran',
//     '32 - El Bayadh',
//     '33 - Illizi',
//     '34 - Bordj Bou Arréridj',
//     '35 - Boumerdès',
//     '36 - El Tarf',
//     '37 - Tindouf',
//     '38 - Tissemsilt',
//     '39 - El Oued',
//     '40 - Khenchela',
//     '41 - Souk Ahras',
//     '42 - Tipaza',
//     '43 - Mila',
//     '44 - Aïn Defla',
//     '45 - Naâma',
//     '46 - Aïn Témouchent',
//     '47 - Ghardaïa',
//     '48 - Relizane',
//     '49 - Timimoun',
//     '50 - Bordj Badji Mokhtar',
//     '51 - Ouled Djellal',
//     '52 - Béni Abbès',
//     '53 - In Salah',
//     '54 - In Guezzam',
//     '55 - Touggourt',
//     '56 - Djanet',
//     '57 - El M\'Ghair',
//     '58 - El Meniaa',
//   ];

//   @override
//   void dispose() {
//     _adresse.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // Parse and simplify error messages
//   String _parseErrorMessage(dynamic errorData) {
//     if (errorData is String) {
//       return _simplifyErrorMessage(errorData);
//     }
    
//     if (errorData is Map) {
//       // Check for 'detail' field first (FastAPI standard)
//       if (errorData.containsKey('detail')) {
//         return _simplifyErrorMessage(errorData['detail'].toString());
//       }
      
//       // Check for validation errors
//       if (errorData.containsKey('message')) {
//         return _simplifyErrorMessage(errorData['message'].toString());
//       }
      
//       // Handle field-specific errors
//       List<String> errors = [];
//       errorData.forEach((key, value) {
//         if (key != 'detail' && key != 'message') {
//           String fieldName = _formatFieldName(key);
//           String fieldError = value is List ? value.join(', ') : value.toString();
//           errors.add('$fieldName: ${_simplifyErrorMessage(fieldError)}');
//         }
//       });
      
//       if (errors.isNotEmpty) {
//         return errors.join('\n');
//       }
      
//       return errorData.toString();
//     }
    
//     return _simplifyErrorMessage(errorData.toString());
//   }

//   // Simplify error messages to be user-friendly
//   String _simplifyErrorMessage(String message) {
//     // Handle duplicate key errors
//     if (message.contains('duplicate key value violates unique constraint')) {
//       if (message.contains('username')) {
//         return 'This username is already taken. Please choose another one.';
//       }
//       if (message.contains('email')) {
//         return 'This email is already registered. Please use another email or login.';
//       }
//       if (message.contains('phone')) {
//         return 'This phone number is already registered.';
//       }
//       return 'This information is already registered. Please check your input.';
//     }
    
//     // Handle unique constraint errors
//     if (message.contains('UniqueViolation')) {
//       if (message.contains('username')) {
//         return 'Username already exists';
//       }
//       if (message.contains('email')) {
//         return 'Email already registered';
//       }
//       if (message.contains('phone')) {
//         return 'Phone number already registered';
//       }
//     }
    
//     // Handle French error messages from your backend
//     if (message.contains('déjà utilisé')) {
//       return message; // Keep French messages as is
//     }
    
//     // Clean up SQL errors
//     if (message.contains('[SQL:') || message.contains('DETAIL:')) {
//       if (message.contains('username')) {
//         return 'This username is already taken';
//       }
//       if (message.contains('email')) {
//         return 'This email is already registered';
//       }
//       if (message.contains('phone')) {
//         return 'This phone number is already registered';
//       }
//       return 'Registration failed. Please check your information.';
//     }
    
//     return message;
//   }

//   // Show clean error dialog
//   void _showErrorDialog(String title, dynamic errorData) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     String errorMessage = _parseErrorMessage(errorData);
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
//           title: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.error_outline_rounded,
//                   color: Colors.red,
//                   size: 48,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           content: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Text(
//               errorMessage,
//               style: TextStyle(
//                 fontSize: 15,
//                 color: isDark ? Colors.grey[300] : Colors.grey[700],
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           actions: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'OK',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//         );
//       },
//     );
//   }

//   // Format field names to be more readable
//   String _formatFieldName(String field) {
//     // Convert snake_case to Title Case
//     return field
//         .replaceAll('_', ' ')
//         .split(' ')
//         .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
//         .join(' ');
//   }

//   // Show success dialog
//   void _showSuccessDialog() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
//           title: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_outline_rounded,
//                   color: Colors.green,
//                   size: 48,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Registration Successful!',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//           content: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Text(
//               'Your account has been created successfully. Please login to continue.',
//               style: TextStyle(
//                 fontSize: 15,
//                 color: isDark ? Colors.grey[300] : Colors.grey[700],
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           actions: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   context.go('/login');
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Go to Login',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//         );
//       },
//     );
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final registrationData = {
//         'username': _nameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'phone_number': _phoneController.text.trim(),
//         'password': _passwordController.text,
//         'address': _adresse.text.trim(),
//         'city': _selectedCity!,
//       };
      
//       print('Sending registration data: $registrationData');

//       final response = await ApiService().registerClient(registrationData);

//       print('Registration response: ${response.data}');

//       if (mounted) {
//         _showSuccessDialog();
//       }
//     } on DioException catch (e) {
//       print('Error status: ${e.response?.statusCode}');
//       print('Error data: ${e.response?.data}');
      
//       if (mounted) {
//         if (e.response?.data != null) {
//           // Show organized error dialog
//           _showErrorDialog('Registration Failed', e.response!.data);
//         } else {
//           // Show generic error
//           _showErrorDialog(
//             'Connection Error',
//             {'Error': e.message ?? 'Could not connect to server. Please check your internet connection.'}
//           );
//         }
//       }
//     } catch (e) {
//       print('Unexpected error: $e');
//       if (mounted) {
//         _showErrorDialog(
//           'Unexpected Error',
//           {'Error': e.toString()}
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = Theme.of(context).colorScheme.primary;
//     final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
//     final cardColor = Theme.of(context).cardColor;
//     final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
//     final subtitleColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Icon(
//                       Icons.medical_services_rounded,
//                       size: 50,
//                       color: isDark ? Colors.white : Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     'Create Account',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: primaryColor,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Join our medical products platform',
//                     style: TextStyle(fontSize: 14, color: subtitleColor),
//                   ),
//                   const SizedBox(height: 32),
//                   _buildTextField(
//                     controller: _nameController,
//                     label: 'Full Name',
//                     icon: Icons.person_outline,
//                     isPasswordField: false,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _emailController,
//                     label: 'Email',
//                     icon: Icons.email_outlined,
//                     isPasswordField: false,
//                     isEmail: true,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _phoneController,
//                     label: 'Phone Number',
//                     icon: Icons.phone_outlined,
//                     isPasswordField: false,
//                     isPhone: true,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _passwordController,
//                     label: 'Password',
//                     icon: Icons.lock_outline,
//                     isPasswordField: true,
//                     isPassword: true,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _confirmPasswordController,
//                     label: 'Confirm Password',
//                     icon: Icons.lock_outline,
//                     isPasswordField: true,
//                     isConfirmPassword: true,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     controller: _adresse,
//                     label: 'Adresse',
//                     icon: Icons.location_on_outlined,
//                     isPasswordField: false,
//                     isDark: isDark,
//                     primaryColor: primaryColor,
//                     cardColor: cardColor,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildCityDropdown(isDark, primaryColor, cardColor),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 54,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _register,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'Register',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Already have an account? ',
//                         style: TextStyle(color: subtitleColor),
//                       ),
//                       GestureDetector(
//                         onTap: () => context.go('/login'),
//                         child: Text(
//                           'Login',
//                           style: TextStyle(
//                             color: primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCityDropdown(bool isDark, Color primaryColor, Color cardColor) {
//     final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    
//     return DropdownButtonFormField<String>(
//       value: _selectedCity,
//       decoration: InputDecoration(
//         labelText: 'Ville',
//         labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
//         prefixIcon: Icon(Icons.location_city_outlined, color: primaryColor),
//         filled: true,
//         fillColor: cardColor,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: borderColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//       ),
//       dropdownColor: cardColor,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black),
//       icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey[400] : Colors.grey),
//       isExpanded: true,
//       items: _algerianCities.map((String city) {
//         return DropdownMenuItem<String>(
//           value: city,
//           child: Text(city),
//         );
//       }).toList(),
//       onChanged: (String? newValue) {
//         setState(() {
//           _selectedCity = newValue;
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select your city';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required bool isPasswordField,
//     required bool isDark,
//     required Color primaryColor,
//     required Color cardColor,
//     bool isEmail = false,
//     bool isPhone = false,
//     bool isPassword = false,
//     bool isConfirmPassword = false,
//   }) {
//     final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    
//     return TextFormField(
//       controller: controller,
//       obscureText: isPasswordField && (isPassword ? _obscurePassword : _obscureConfirmPassword),
//       keyboardType: isEmail
//           ? TextInputType.emailAddress
//           : (isPhone ? TextInputType.phone : TextInputType.text),
//       style: TextStyle(color: isDark ? Colors.white : Colors.black),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
//         prefixIcon: Icon(icon, color: primaryColor),
//         suffixIcon: isPasswordField
//             ? IconButton(
//                 icon: Icon(
//                   isPassword
//                       ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
//                       : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
//                   color: isDark ? Colors.grey[400] : Colors.grey,
//                 ),
//                 onPressed: () => setState(() => isPassword
//                     ? _obscurePassword = !_obscurePassword
//                     : _obscureConfirmPassword = !_obscureConfirmPassword),
//               )
//             : null,
//         filled: true,
//         fillColor: cardColor,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: borderColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: primaryColor, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) return 'Please enter your $label';
//         if (isEmail && !value!.contains('@')) return 'Please enter a valid email';
//         if (isPhone && value!.length < 10) return 'Please enter a valid phone number';
//         if (isPassword && value!.length < 6) return 'Password must be at least 6 characters';
//         if (isConfirmPassword && value != _passwordController.text) return 'Passwords do not match';
//         return null;
//       },
//     );
//   }
// }