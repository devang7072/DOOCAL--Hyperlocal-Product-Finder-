import 'package:flutter/foundation.dart';

class AnalyticsService {
  void logEvent(String name, Map<String, dynamic> parameters) {
    // Integrate with Firebase Analytics here
    debugPrint('Analytics Event: $name, Params: $parameters');
  }

  void logRequestCreated(String category) {
    logEvent('request_created', {'category': category});
  }

  void logVendorResponse(String vendorId) {
    logEvent('vendor_response', {'vendorId': vendorId});
  }
}
