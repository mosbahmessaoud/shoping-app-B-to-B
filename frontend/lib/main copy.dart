// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'routes/app_router.dart';
// import 'core/services/notification_service.dart';
// import 'data/providers/theme_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize notification service
//   await NotificationService().initialize();
  
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, _) {
//           final appRouter = AppRouter();

//           return MaterialApp.router(
//             title: 'E-Commerce App',
//             debugShowCheckedModeBanner: false,
//             themeMode: themeProvider.themeMode,
//             theme: ThemeData(
//               colorScheme: ColorScheme.fromSeed(
//                 seedColor: Colors.blue,
//                 brightness: Brightness.light,
//               ),
//               useMaterial3: true,
//               appBarTheme: const AppBarTheme(
//                 centerTitle: true,
//                 elevation: 0,
//               ),
//               cardTheme: const CardThemeData(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//               ),
//               inputDecorationTheme: const InputDecorationTheme(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//                 filled: true,
//               ),
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             darkTheme: ThemeData(
//               colorScheme: ColorScheme.fromSeed(
//                 seedColor: Colors.blue,
//                 brightness: Brightness.dark,
//               ),
//               useMaterial3: true,
//               appBarTheme: const AppBarTheme(
//                 centerTitle: true,
//                 elevation: 0,
//               ),
//               cardTheme: const CardThemeData(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//               ),
//               inputDecorationTheme: const InputDecorationTheme(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(12)),
//                 ),
//                 filled: true,
//               ),
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             routerConfig: appRouter.router,
//           );
//         },
//       ),
//     );
//   }
// }