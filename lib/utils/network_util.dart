import 'dart:io';

class NetworkUtil {
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      // For Android emulator, use 10.0.2.2 to access host's localhost
      // For physical devices, you might need to use your computer's actual IP
      return 'http://10.0.2.2:8080/api/v1';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost:8080/api/v1';
    } else {
      // Default fallback
      return 'http://localhost:8080/api/v1';
    }
  }
  
  // Method to get a dynamic base URL that can be configured at runtime
  static Future<String> getDynamicBaseUrl() async {
    // This could be expanded to read from shared preferences or a config file
    return getBaseUrl();
  }
}