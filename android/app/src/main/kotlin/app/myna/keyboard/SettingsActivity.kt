// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard

import app.myna.keyboard.bridge.AppFlutterApi
import app.myna.keyboard.bridge.AppHostApi
import app.myna.keyboard.bridge.AppHostApiImpl
import app.myna.keyboard.bridge.EngineRole
import app.myna.keyboard.bridge.PlatformHostApi
import app.myna.keyboard.bridge.PlatformHostApiImpl
import app.myna.keyboard.bridge.SettingsBus
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * The settings app (onboarding, themes, privacy center). A FragmentActivity
 * because local_auth's BiometricPrompt requires one.
 */
class SettingsActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        PlatformHostApi.setUp(messenger, PlatformHostApiImpl(applicationContext, EngineRole.APP))
        AppHostApi.setUp(messenger, AppHostApiImpl(this))
        SettingsBus.attachApp(AppFlutterApi(messenger))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        SettingsBus.attachApp(null)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        PlatformHostApi.setUp(messenger, null)
        AppHostApi.setUp(messenger, null)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
