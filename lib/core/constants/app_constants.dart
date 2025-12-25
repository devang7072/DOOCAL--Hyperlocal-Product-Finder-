// lib/core/constants/app_constants.dart

class AppConstants {
  static const String appName = 'DOOCAL';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String isFirstTimeKey = 'is_first_time';
  
  // Map Config
  static const double defaultZoom = 14.4746;
  static const double searchRadius = 5.0; // km
  
  // Categories
  static const List<String> categories = [
    'Grocery',
    'Pharmacy',
    'Electronics',
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Mechanic',
    'Laundry',
  ];
}
