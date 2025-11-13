# Mobile App Configuration for Deployed Backend

This guide explains how to configure your Flutter mobile app to connect to the deployed Railway backend API.

## Railway API URL

After deploying to Railway, you'll receive a public URL like:
```
https://your-app-name.railway.app
```

Your API base URL will be:
```
https://your-app-name.railway.app/api
```

## Configuration Methods

The mobile app supports multiple ways to configure the API URL. Choose the method that works best for your testing scenario.

### Method 1: Runtime Configuration (Recommended for Testing)

The mobile app already has built-in support for runtime API URL configuration using `AppConfig.setApiBaseUrl()`.

#### Option A: Set API URL in App Settings (if implemented)

If your app has a settings screen with API configuration:
1. Open the app
2. Navigate to Settings
3. Enter the Railway API URL: `https://your-app-name.railway.app/api`
4. Save and restart the app

#### Option B: Programmatically Set API URL

You can add a temporary configuration in your app initialization code:

```dart
// In your main.dart or app initialization
import 'package:digital_nurse/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set Railway API URL
  await AppConfig.setApiBaseUrl('https://your-app-name.railway.app/api');
  
  runApp(MyApp());
}
```

### Method 2: Build-Time Configuration

Configure the API URL at build time using Dart's environment variables.

#### For Android APK:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.railway.app/api
```

#### For Android App Bundle:

```bash
flutter build appbundle --dart-define=API_BASE_URL=https://your-app-name.railway.app/api
```

The app will automatically use this URL if no runtime configuration is set.

### Method 3: Modify AppConfig Default (Development Only)

For quick testing, you can temporarily modify the default URL in `mobile/lib/core/config/app_config.dart`:

```dart
// Change the default URL
static const String _defaultLocalhost = 'https://your-app-name.railway.app/api';
```

**Note**: Remember to revert this change before committing to version control.

## Testing on Physical Android Device

### Step 1: Build APK with Railway URL

```bash
cd mobile
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.railway.app/api
```

### Step 2: Install APK on Device

1. Transfer the APK file to your Android device:
   - Location: `mobile/build/app/outputs/flutter-apk/app-release.apk`
   - Use USB, email, or cloud storage

2. On your Android device:
   - Enable "Install from Unknown Sources" in Settings
   - Open the APK file
   - Install the app

### Step 3: Verify Connection

1. Open the app on your device
2. Try to register or login
3. Check app logs (if available) or use Flutter DevTools to verify API calls
4. Verify requests are going to your Railway URL

## Network Security Configuration

For Android, ensure your `network_security_config.xml` allows HTTPS connections to Railway:

The file `mobile/android/app/src/main/res/xml/network_security_config.xml` should allow cleartext traffic for testing (if needed) or properly configure HTTPS:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

**Note**: Railway uses HTTPS by default, so cleartext traffic permission is only needed if you're testing with HTTP endpoints.

## Debugging Connection Issues

### Check API URL is Set Correctly

Add logging in your app to verify the API URL:

```dart
final apiUrl = await AppConfig.getBaseUrl();
print('Current API URL: $apiUrl');
```

### Test API Endpoint Directly

Test the Railway API from your device's browser or a REST client:

1. Open browser on your Android device
2. Navigate to: `https://your-app-name.railway.app/api/health`
3. You should see a health check response

### Common Issues

1. **Connection Timeout**
   - Verify device has internet connection
   - Check Railway service is running (view logs in Railway dashboard)
   - Verify firewall/network restrictions

2. **SSL Certificate Errors**
   - Railway provides valid SSL certificates automatically
   - If errors occur, check device date/time settings
   - Verify Railway URL is correct

3. **CORS Errors**
   - Railway backend should have `FRONTEND_URL=*` for testing
   - Check Railway environment variables

4. **404 Not Found**
   - Verify API URL includes `/api` suffix
   - Check Railway deployment logs for errors

## Production Considerations

### For Production Builds:

1. **Remove Debug Logging**: Remove or disable API URL logging
2. **Hardcode Production URL**: Use build-time configuration or environment-specific configs
3. **Update CORS**: Set `FRONTEND_URL` to your app's specific origin in Railway
4. **SSL Pinning**: Consider implementing SSL certificate pinning for security

### Environment-Specific Configuration

Create different configurations for different environments:

```dart
class AppConfig {
  static const String _productionUrl = 'https://your-app-name.railway.app/api';
  static const String _stagingUrl = 'https://staging-app.railway.app/api';
  static const String _localUrl = 'http://10.0.2.2:3000/api';
  
  static String getBaseUrlForEnvironment(String env) {
    switch (env) {
      case 'production':
        return _productionUrl;
      case 'staging':
        return _stagingUrl;
      default:
        return _localUrl;
    }
  }
}
```

## Example: Complete Setup

Here's a complete example of configuring the app for Railway:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:digital_nurse/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure API URL for Railway deployment
  const railwayUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-app-name.railway.app/api',
  );
  
  await AppConfig.setApiBaseUrl(railwayUrl);
  
  print('🚀 API Base URL configured: $railwayUrl');
  
  runApp(MyApp());
}
```

Build command:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.railway.app/api
```

## Additional Resources

- [Flutter Build Configuration](https://docs.flutter.dev/deployment/android)
- [Dart Environment Variables](https://dart.dev/guides/language/language-tour#metadata)
- Railway API URL from your Railway dashboard

