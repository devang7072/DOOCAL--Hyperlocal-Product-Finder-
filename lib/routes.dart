// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/customer/customer_main_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';
import 'screens/vendor/vendor_setup_screen.dart';
import 'screens/customer/customer_requests_screen.dart';
import 'screens/vendor/vendor_history_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/customer/vendor_responses_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/vendor/vendor_onboarding_benefits.dart';
import 'screens/vendor/vendor_catalog_screen.dart';
import 'screens/customer/create_request_screen.dart';
import 'screens/customer/customer_profile_screen.dart';
import 'models/request_model.dart';
import 'screens/demo/component_demo_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String roleSelection = '/role_selection';
  static const String customerHome = '/customer_home';
  static const String vendorHome = '/vendor_home';
  static const String vendorSetup = '/vendor_setup';
  static const String customerRequests = '/customer_requests';
  static const String vendorHistory = '/vendor_history';
  static const String vendorResponses = '/vendor_responses';
  static const String chat = '/chat';
  static const String vendorOnboarding = '/vendor_onboarding';
  static const String vendorCatalog = '/vendor_catalog';
  static const String createRequest = '/create_request';
  static const String customerProfile = '/customer_profile';
  static const String demo = '/demo';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.splash: (context) => const SplashScreen(),
  Routes.onboarding: (context) => const OnboardingScreen(),
  Routes.login: (context) => const LoginScreen(),
  Routes.roleSelection: (context) => const RoleSelectionScreen(),
  Routes.customerHome: (context) => const CustomerMainScreen(),
  Routes.vendorHome: (context) => const VendorMainScreen(),
  Routes.vendorSetup: (context) => const VendorSetupScreen(),
  Routes.vendorCatalog: (context) => const VendorCatalogScreen(),
  Routes.createRequest: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return CreateRequestScreen(
      initialItem: args?['initialItem'],
      initialCategory: args?['initialCategory'],
    );
  },
  Routes.customerProfile: (context) => const CustomerProfileScreen(),
  Routes.customerRequests: (context) => const CustomerRequestsScreen(),
  Routes.vendorHistory: (context) => const VendorHistoryScreen(),
  Routes.vendorResponses: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as RequestModel;
    return VendorResponsesScreen(request: args);
  },
  Routes.chat: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return ChatScreen(requestId: args['requestId'], otherPartyName: args['otherPartyName']);
  },
  Routes.vendorOnboarding: (context) => const VendorOnboardingBenefits(),
  Routes.demo: (context) => const ComponentDemoScreen(),
};
