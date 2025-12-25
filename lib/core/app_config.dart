// lib/core/app_config.dart
import 'constants/app_constants.dart';

class AppConfig {
  static const String version = '1.0.0';
  static const String environment = 'production';
  
  static void initialize() {
    // Global initializations
    print('Initializing ${AppConstants.appName} v$version in $environment mode');
  }
}
