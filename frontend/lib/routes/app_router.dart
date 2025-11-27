
// ============================================
// APP ROUTER - app_router.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:store_app/presentation/screens/admin/admin_add_product.dart';
import 'package:store_app/presentation/screens/admin/admin_bills_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_categories_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_clients_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_edit_bill.dart';
import 'package:store_app/presentation/screens/admin/admin_edit_product.dart';
import 'package:store_app/presentation/screens/admin/admin_notifications_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_payments_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_products_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_profile_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_statistics_screen.dart';
import 'package:store_app/presentation/screens/admin/admin_stock_alerts_screen.dart';
import 'package:store_app/presentation/screens/client/bill_detail_screen.dart';
import 'package:store_app/presentation/screens/client/cart_screen.dart';
import 'package:store_app/presentation/screens/client/client_home_screen.dart';
import 'package:store_app/presentation/screens/client/client_profile_screen.dart';
import 'package:store_app/presentation/screens/client/my_bills_screen.dart';
import 'package:store_app/presentation/screens/client/product_detail_screen.dart';
import 'package:store_app/presentation/screens/client/products_list_screen.dart';
import '../core/services/auth_service.dart';

// Import screens
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';

class AppRouter {
  final AuthService _authService = AuthService();

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final isLoggedIn = await _authService.isLoggedIn();
      final userType = await _authService.getUserType();
      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';
      final isSplashRoute = state.uri.path == '/splash';

      // Allow splash screen
      if (isSplashRoute) return null;
      
      // Redirect to login if not logged in and not already on auth pages
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }
      
      // Redirect logged-in users away from auth pages to their dashboard
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return userType == 'admin' ? '/admin/dashboard' : '/client/home';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes - Unified Login
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Client Routes
      GoRoute(
        path: '/client/home',
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: '/client/profile',
        builder: (context, state) => const ClientProfileScreen(),
      ),
      GoRoute(
        path: '/client/products',
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: '/client/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/client/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/client/bills',
        builder: (context, state) => const MyBillsScreen(),
      ),
      GoRoute(
        path: '/client/bill/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BillDetailScreen(billId: id);
        }
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/clients',
        builder: (context, state) => const AdminClientsScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/product/add',
        builder: (context, state) => const AdminAddProductScreen(),
      ),
      GoRoute(
        path: '/admin/product/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdminEditProductScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/bills',
        builder: (context, state) => const AdminBillsScreen(),
      ),
      GoRoute(
        path: '/admin/bill/:id',
        builder: (context, state) {
          final billId = state.pathParameters['id']!;
          return AdminEditBillScreen(billId: billId);
        },
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/stock-alerts',
        builder: (context, state) => const AdminStockAlertsScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/profile',
        builder: (context, state) => const AdminProfileScreen(),
      ),
      GoRoute(path: '/admin/statistics',
        builder: (context, state) => const AdminStatisticsScreen()
      ),
    ],
  );
}