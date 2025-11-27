// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../core/services/auth_service.dart';

// // Import screens (you'll create these)
// import '../presentation/screens/auth/login_screen.dart';
// import '../presentation/screens/auth/register_screen.dart';
// import '../presentation/screens/auth/splash_screen.dart';

// class AppRouter {
//   final AuthService _authService = AuthService();

//   late final GoRouter router = GoRouter(
//     initialLocation: '/splash',
//     redirect: (context, state) async {
//       final isLoggedIn = await _authService.isLoggedIn();
//       final userType = await _authService.getUserType();
//       final isLoginRoute = state.uri.path.contains('/login');
//       final isRegisterRoute = state.uri.path == '/register';
//       final isSplashRoute = state.uri.path == '/splash';

//       if (isSplashRoute) return null;
//       if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) return '/login/client';
//       if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
//         return userType == 'admin' ? '/admin/dashboard' : '/client/home';
//       }
//       return null;
//     },
//     routes: [
//       // Splash Screen
//       GoRoute(
//         path: '/splash',
//         builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       ),

//       // Auth Routes
//       GoRoute(
//         path: '/login/client',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Client Login'))),
//       ),
//       GoRoute(
//         path: '/login/admin',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Login'))),
//       ),
//       GoRoute(
//         path: '/register',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Register'))),
//       ),

//       // Client Routes
//       GoRoute(
//         path: '/client/home',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Client Home'))),
//       ),
//       GoRoute(
//         path: '/client/profile',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Client Profile'))),
//       ),
//       GoRoute(
//         path: '/client/products',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Products'))),
//       ),
//       GoRoute(
//         path: '/client/product/:id',
//         builder: (context, state) => Scaffold(
//           body: Center(child: Text('Product Detail ${state.pathParameters['id']}')),
//         ),
//       ),
//       GoRoute(
//         path: '/client/cart',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Cart'))),
//       ),
//       GoRoute(
//         path: '/client/bills',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('My Bills'))),
//       ),
//       GoRoute(
//         path: '/client/bill/:id',
//         builder: (context, state) => Scaffold(
//           body: Center(child: Text('Bill Detail ${state.pathParameters['id']}')),
//         ),
//       ),

//       // Admin Routes
//       GoRoute(
//         path: '/admin/dashboard',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Dashboard'))),
//       ),
//       GoRoute(
//         path: '/admin/clients',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Manage Clients'))),
//       ),
//       GoRoute(
//         path: '/admin/products',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Manage Products'))),
//       ),
//       GoRoute(
//         path: '/admin/product/add',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Add Product'))),
//       ),
//       GoRoute(
//         path: '/admin/product/edit/:id',
//         builder: (context, state) => Scaffold(
//           body: Center(child: Text('Edit Product ${state.pathParameters['id']}')),
//         ),
//       ),
//       GoRoute(
//         path: '/admin/categories',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Manage Categories'))),
//       ),
//       GoRoute(
//         path: '/admin/bills',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('All Bills'))),
//       ),
//       GoRoute(
//         path: '/admin/bill/:id',
//         builder: (context, state) => Scaffold(
//           body: Center(child: Text('Bill Detail ${state.pathParameters['id']}')),
//         ),
//       ),
//       GoRoute(
//         path: '/admin/payments',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Payments'))),
//       ),
//       GoRoute(
//         path: '/admin/stock-alerts',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Stock Alerts'))),
//       ),
//       GoRoute(
//         path: '/admin/notifications',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Notifications'))),
//       ),
//       GoRoute(
//         path: '/admin/profile',
//         builder: (context, state) => const Scaffold(body: Center(child: Text('Admin Profile'))),
//       ),
//     ],
//   );
// }