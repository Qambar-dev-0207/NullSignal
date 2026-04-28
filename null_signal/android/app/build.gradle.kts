import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.nullsignal.null_signal"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nullsignal.null_signal"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 31
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val properties = Properties()
        val localPropertiesFile = project.rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            properties.load(FileInputStream(localPropertiesFile))
        }
        val hfToken = properties.getProperty("hf.token", "")
        buildConfigField("String", "HF_TOKEN", "\"$hfToken\"")
    }

    buildFeatures {
        buildConfig = true
    }

    // Keep the bundled Gemma .task model uncompressed inside the APK so the OS
    // can mmap it directly. Compressed assets must be fully extracted at runtime
    // and would double both install time and disk usage for a 2 GB model.
    androidResources {
        noCompress += listOf("task", "litertlm", "tflite", "bin")
    }

    // The packaged model is large (~2 GB). The default 2 GB APK upper limit on
    // Android may be hit; allow bundle splits per ABI in release if you need to.
    packaging {
        resources {
            excludes += listOf("META-INF/DEPENDENCIES", "META-INF/LICENSE")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.google.mediapipe:tasks-genai:0.10.33")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}

flutter {
    source = "../.."
}
