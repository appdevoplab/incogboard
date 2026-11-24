# IncogBoard release shrinker rules. The Flutter Gradle plugin adds the Flutter engine's own keep rules.

# Privacy: no debug/verbose/info logging in shipped builds. R8 removes the calls and their
# argument construction, so nothing typed can ever reach logcat through these levels.
# (Warnings and errors stay; IncogBoard only logs events, sizes and timings, never text.)
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# Pigeon-generated bridge: message classes are built reflection-free, but keep them readable in
# stack traces and safe from over-eager optimisation of the channel codec.
-keep class app.incogboard.keyboard.bridge.** { *; }

# The system instantiates these by name from the manifest.
-keep class app.incogboard.keyboard.ime.IncogBoardImeService { *; }
-keep class app.incogboard.keyboard.SettingsActivity { *; }
-keep class app.incogboard.keyboard.IncogBoardApplication { *; }

# Wave 3: native inference. JNI looks these classes, fields and methods up by name.
-keep class com.k2fsa.sherpa.onnx.** { *; }
-keep class ai.onnxruntime.** { *; }
