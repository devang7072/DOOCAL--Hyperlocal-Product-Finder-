// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/chat_provider.dart';

// If you used firebase CLI to generate firebase_options.dart, import it and initialize with options.
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // or Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DOOCAL',
        theme: AppTheme.lightTheme,
        initialRoute: Routes.splash,
        routes: appRoutes,
      ),
    );
  }
}
