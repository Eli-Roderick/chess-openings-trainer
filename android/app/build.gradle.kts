import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (docs/plan/phases/P00-bootstrap.md task 10). The keystore and
// its passwords live in android/key.properties (gitignored; see
// key.properties.example). Without it, release builds fall back to debug
// signing so local and secret-less CI builds still work.
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties =
    Properties().apply {
        if (keyPropertiesFile.exists()) {
            keyPropertiesFile.inputStream().use { load(it) }
        }
    }
val hasReleaseKey = keyPropertiesFile.exists()

android {
    namespace = "dev.eliroderick.repertoiretrainer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.eliroderick.repertoiretrainer"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // From pubspec.yaml. With --split-per-abi Flutter adds 1000 * ABI_VERSION.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (hasReleaseKey) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }

    // Stockfish ships as jniLibs/<abi>/libstockfish.so and is executed from
    // nativeLibraryDir, so it must be extracted on install (docs/plan/05-engine.md §2).
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
