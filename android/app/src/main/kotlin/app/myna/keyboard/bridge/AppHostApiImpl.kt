// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.bridge

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager

/**
 * Calls for the settings-app engine.
 *
 * OWNER: orchestrator, except the backup section at the bottom, which Wave 2-B implements
 * (Storage Access Framework documents and .mynabackup crypto; put helpers in `security/backup/`).
 */
internal class AppHostApiImpl(
    private val activity: Activity,
    private val launchRoute: () -> String?,
) : AppHostApi {

    private val imm get() = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager

    override fun isMynaEnabled() = imm.enabledInputMethodList.any { it.packageName == activity.packageName }

    override fun isMynaSelected(): Boolean {
        val id = Settings.Secure.getString(activity.contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
            ?: return false
        return id.startsWith(activity.packageName + "/")
    }

    override fun openInputMethodSettings() {
        activity.startActivity(Intent(Settings.ACTION_INPUT_METHOD_SETTINGS))
    }

    override fun showInputMethodPicker() = imm.showInputMethodPicker()

    override fun setSecureScreen(secure: Boolean) {
        activity.runOnUiThread {
            if (secure) activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            else activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            if (Build.VERSION.SDK_INT >= 33) activity.setRecentsScreenshotEnabled(!secure)
        }
    }

    override fun takeLaunchRoute(): String? = launchRoute()

    // ---- Backup files and crypto: Wave 2-B ---------------------------------------------

    // Pigeon runs these suspend functions on Dispatchers.Main.
    override suspend fun createDocument(suggestedName: String, mimeType: String): String? = throw notImplemented()

    override suspend fun openDocument(mimeTypes: List<String>): String? = throw notImplemented()

    override fun writeDocument(uri: String, data: ByteArray): Unit = throw notImplemented()

    override fun readDocument(uri: String, maxBytes: Long): ByteArray = throw notImplemented()

    override fun sealBackup(plain: ByteArray, passphrase: String): ByteArray = throw notImplemented()

    override fun openBackup(sealed: ByteArray, passphrase: String): ByteArray? = throw notImplemented()

    private fun notImplemented() = FlutterError("unimplemented", "backup is implemented in Wave 2-B", null)
}
