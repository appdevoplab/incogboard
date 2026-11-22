plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.kosha.keyboard"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.kosha.keyboard" // PLACEHOLDER: becomes io.github.<username>.kosha before the first store release
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26 // PBKDF2-SHA256, modern Keystore, contentMimeTypes
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // R8 also strips android.util.Log.d/v/i (see proguard-rules.pro): no debug logging in shipped builds.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    // Inline autofill chip styling (UiVersions). Pure UI helpers, Apache-2.0, no network code.
    implementation("androidx.autofill:autofill:1.3.0")
    // Pigeon's @async host methods are generated as suspend functions. Already on the classpath
    // through AndroidX (same version); pinned so the generated bindings don't rely on that. Apache-2.0.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")

    // ONNX Runtime (MIT): the one native inference runtime, shared by voice (sherpa-onnx, Wave 3-D) and
    // translation (Wave 3-T). Pinned to 1.28.0: 1.29+ adds an HTTP telemetry client, a startup provider,
    // INTERNET and ACCESS_NETWORK_STATE. Do not upgrade without checking the AAR manifest and classes.
    // No network code. Nothing else may bundle its own libonnxruntime.so.
    implementation("com.microsoft.onnxruntime:onnxruntime-android:1.28.0")

    testImplementation("junit:junit:4.13.2")
    // Real org.json for JVM tests (Android's stub throws "not mocked").
    testImplementation("org.json:json:20240303")
    testImplementation("com.microsoft.onnxruntime:onnxruntime:1.28.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
