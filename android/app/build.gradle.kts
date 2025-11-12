plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.navex.navex"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        //(***required for flutter-local-notifications package)
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.navex.navexapp"
        minSdk = 24 //flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.4"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Use correct Kotlin DSL syntax for dependencies
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")

    // ✅ Firebase BOM (Bill of Materials) - ensures all Firebase dependencies use compatible versions
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    
    // Firebase dependencies will automatically use versions from BOM
    // Uncomment these if you need specific Firebase services:
    // implementation("com.google.firebase:firebase-firestore")
    // implementation("com.google.firebase:firebase-messaging")
    // implementation("com.google.firebase:firebase-analytics")

    // ✅ Add this for desugaring support - (***required for flutter-local-notifications package)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
