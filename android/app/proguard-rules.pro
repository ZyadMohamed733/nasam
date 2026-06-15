# Keep Flutter engine
-keep class io.flutter.** { *; }

# Keep Dio models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Injectable / GetIt
-keep class * implements javax.inject.Provider { *; }

# Prevent class name exposure
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
