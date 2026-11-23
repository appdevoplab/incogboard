import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// -----------------------------------------------------------------------------------------------
// Release identity. ONE place for the applicationId.
// The value is a PLACEHOLDER until the store release: it becomes io.github.<username>.kosha once the
// username is known. Change it only with tool/release/set_application_id.ps1, which rewrites this
// line and every other place listed in docs/release/RELEASING.md ("applicationId" section).
// The namespace (Kotlin package, R class, JNI names) stays app.kosha.keyboard for good.
// -----------------------------------------------------------------------------------------------
val koshaApplicationId = "app.kosha.keyboard" // PLACEHOLDER: becomes io.github.<username>.kosha
val koshaNamespace = "app.kosha.keyboard"

// Pinned NDK. Flutter 3.50.0 defaults to the same version; the pin keeps it from moving with the SDK.
// Flutter version: tool/release/flutter-version.txt. Gradle: android/gradle/wrapper (9.5.0).
val koshaNdkVersion = "28.2.13676358"

// -----------------------------------------------------------------------------------------------
// Release signing. Read from android/key.properties (git-ignored; keys: storeFile, storePassword,
// keyAlias, keyPassword) or from KOSHA_KEYSTORE_PATH, KOSHA_KEYSTORE_PASSWORD, KOSHA_KEY_ALIAS,
// KOSHA_KEY_PASSWORD. storeFile must be an absolute path outside the repository.
// With neither present, release builds fall back to the debug key and print a warning, so
// contributors and CI without secrets can still build. release.yml refuses debug-signed output.
// -----------------------------------------------------------------------------------------------
val signingProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

fun signingSetting(propertyKey: String, envKey: String): String? =
    (signingProperties.getProperty(propertyKey) ?: System.getenv(envKey))?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingSetting("storeFile", "KOSHA_KEYSTORE_PATH")
val releaseStorePassword = signingSetting("storePassword", "KOSHA_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingSetting("keyAlias", "KOSHA_KEY_ALIAS")
val releaseKeyPassword = signingSetting("keyPassword", "KOSHA_KEY_PASSWORD")
val hasReleaseSigning =
    listOf(releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword).all { it != null }

android {
    namespace = koshaNamespace
    compileSdk = flutter.compileSdkVersion
    ndkVersion = koshaNdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Two distributions of the same code. Only Gradle and resources differ (src/foss, src/play).
    //   foss: GitHub and F-Droid. The full build, signed-pack import, no Google libraries.
    //   play: Google Play. Same code; large data arrives as Play on-demand asset packs (Wave 5-C).
    // Until the asset-pack modules land, play behaves exactly like foss.
    flavorDimensions += "distribution"
    productFlavors {
        create("foss") {
            dimension = "distribution"
        }
        create("play") {
            dimension = "distribution"
        }
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword!!
                keyAlias = releaseKeyAlias!!
                keyPassword = releaseKeyPassword!!
            }
        }
    }

    defaultConfig {
        applicationId = koshaApplicationId
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26 // PBKDF2-SHA256, modern Keystore, contentMimeTypes
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        // Set the version with tool/release/bump_version.ps1 (it edits the pubspec version line).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Vital lint on release builds crashes inside the lint tool (a JavaDoc parser mismatch while
    // scanning ExifDataCopier.java in a dependency; reproduced on the play flavour, AGP 9.3 / Kotlin 2.4).
    // That is a tool bug, not Kosha code, and it blocks assemble*Release. Release builds skip vital
    // lint; run lint on the debug build instead. Re-enable when the lint tool is fixed.
    lint {
        checkReleaseBuilds = false
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // R8 also strips android.util.Log.d/v/i (see proguard-rules.pro): no debug logging in shipped builds.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// Loud warning when a release task runs without release keys. The APK is then debug-signed and must not be published.
gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any {
        (it.name.startsWith("assemble") || it.name.startsWith("bundle")) && it.name.contains("Release")
    }
    if (releaseRequested && !hasReleaseSigning) {
        logger.warn(
            "WARNING: no release signing configured (android/key.properties or KOSHA_KEYSTORE_* variables). " +
                "The release build is signed with the DEBUG key. Do not publish it; see docs/release/RELEASING.md.",
        )
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

// Locked dependency versions: android/app/gradle.lockfile. Regenerate with
// `cd android; .\gradlew.bat :app:dependencies --write-locks` after a deliberate dependency change.
dependencyLocking {
    lockAllConfigurations()
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
