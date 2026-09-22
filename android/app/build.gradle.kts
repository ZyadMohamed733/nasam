import java.util.Properties

plugins {
    id("com.android.application")
   // id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

}

// Release signing credentials, kept out of version control. See
// android/key.properties.example for the required keys.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

// Local .env is never bundled as a Flutter asset. CI can supply the variable.
val mapsEnvFile = rootProject.file("../.env")
val mapsEnv = Properties().apply {
    if (mapsEnvFile.exists()) mapsEnvFile.inputStream().use { load(it) }
}
val mapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY")
    ?: mapsEnv.getProperty("GOOGLE_MAPS_API_KEY", "").trim().trim('"', '\'')
require(mapsApiKey.isNotBlank()) { "Set GOOGLE_MAPS_API_KEY in .env or the build environment" }

android {
    namespace = "com.nasam.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nasam.app"
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // --- Flavor setup ---
    flavorDimensions += "environment"
    productFlavors{
        create("dev"){
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue(type = "string", name = "app_name", value = "Nasam Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            resValue(type = "string", name = "app_name", value = "Nasam Staging")
        }
        create("prod") {
            dimension = "environment"
            // No suffix -> this is what ships to the Play Store as com.nasam.app
            resValue(type = "string", name = "app_name", value = "Nasam")
        }
    }
    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Never fall back to the debug keystore: that key ships inside every
            // Android SDK, Play rejects it, and the failure is silent.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                null
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Fails the build rather than quietly emitting an unsigned or debug-signed
// release artifact. Only fires when a release task is actually in the graph.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { it.name.contains("Release") }
    if (buildingRelease && !hasReleaseKeystore) {
        throw GradleException(
            "Release build requested but android/key.properties is missing. " +
                "Copy android/key.properties.example, point storeFile at your " +
                "keystore, and keep both out of version control."
        )
    }
}

flutter {
    source = "../.."
}
