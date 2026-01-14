# --- REQUIRED FOR flutter_local_notifications (Gson TypeToken issue) ---
-keepattributes Signature
-keepattributes *Annotation*

# Keep Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep flutter_local_notifications internals
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Prevent R8 from stripping generic info
-keep class * extends com.google.gson.reflect.TypeToken