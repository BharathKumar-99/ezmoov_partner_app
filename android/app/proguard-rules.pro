## Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

## Firebase & FCM Rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## Local Notifications & Background Services
-keep class id.flutter.flutter_background_service.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

## Geolocator
-keep class com.baseflow.geolocator.** { *; }
