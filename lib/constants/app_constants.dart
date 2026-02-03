class AppConstants {
  // App Info
  static const String appName = 'POS Desktop';
  static const String version = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'https://your-laravel-api.com'; // Replace with actual backend URL
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5); // Auto-sync interval
  static const Duration sessionTimeout = Duration(minutes: 5); // Session timeout for auto-lock
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  
  // Order Status
  static const String orderPending = 'pending';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';
  
  // Fulfillment Types
  static const String fulfillmentDelivery = 'delivery';
  static const String fulfillmentPickup = 'pickup';
  static const String fulfillmentOnSite = 'on_site';
  
  // Sync Status
  static const String syncStatusSynced = 'synced';
  static const String syncStatusPending = 'pending';
  static const String syncStatusFailed = 'failed';
}