plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream
import java.io.File

// Keystore bilgilerini yükle
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nxadestudios.nxademusic"
<<<<<<< HEAD
    compileSdk = 35  // Android 16 (API level 36)
    // Use an NDK version compatible with current AGP/Flutter
    ndkVersion = "27.0.12077973"

=======
    compileSdk = 36  // Updated for plugin compatibility
    // Use an NDK version compatible with current AGP/Flutter
    ndkVersion = "27.0.12077973"
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.nxadestudios.nxademusic"
        minSdk = 26  // Android 8.1 (API level 26)
<<<<<<< HEAD
        targetSdk = 35
        versionCode = 5
        versionName = "1.12.3"
=======
        targetSdk = 34  // Play Store requirement
        versionCode = 6
        versionName = "1.12.4"
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)

        // Limit ABIs to production targets to avoid x86 cmake issues
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
