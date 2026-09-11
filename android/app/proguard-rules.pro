# Keep Flutter engine
-keep class io.flutter.** { *; }

# This project serialises through json_serializable / Freezed, not Gson, so the
# previous @com.google.gson.annotations.SerializedName rule protected nothing.
# Dart code is compiled AOT and is not touched by R8, so model classes need no
# keep rules; what matters is the plugin surface R8 reaches via reflection.

# Plugin channels and any embedding entry points resolved by name.
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# flutter_secure_storage relies on the AndroidX security/crypto stack.
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# Tink is pulled in by androidx.security and uses reflection internally.
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# OkHttp/Conscrypt are optional at runtime for some networking plugins.
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Keep readable stack traces while still obfuscating class names.
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
