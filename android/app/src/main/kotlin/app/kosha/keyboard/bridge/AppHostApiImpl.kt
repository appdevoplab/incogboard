// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import androidx.activity.ComponentActivity
import android.net.Uri
import app.kosha.keyboard.packs.PackException
import app.kosha.keyboard.packs.PackStore
import app.kosha.keyboard.security.backup.BackupCrypto
import app.kosha.keyboard.security.backup.BackupDocuments
import app.kosha.keyboard.security.backup.BackupException

/**
 * Calls for the settings-app engine.
 *
 * OWNER: orchestrator, except the backup section at the bottom, which Wave 2-B implements
 * (Storage Access Framework documents and .koshabackup crypto; helpers live in `security/backup/`).
 */
internal class AppHostApiImpl(
    private val activity: ComponentActivity,
    private val launchRoute: () -> String?,
) : AppHostApi {

    private val imm get() = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager

    /** Registers the document pickers, so it must be built before the activity starts. */
    private val documents = BackupDocuments(activity)

    override fun isKoshaEnabled() = imm.enabledInputMethodList.any { it.packageName == activity.packageName }

    override fun isKoshaSelected(): Boolean {
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
    override suspend fun createDocument(suggestedName: String, mimeType: String): String? =
        backupErrors { documents.create(suggestedName, mimeType) }

    override suspend fun openDocument(mimeTypes: List<String>): String? =
        backupErrors { documents.open(mimeTypes) }

    override fun writeDocument(uri: String, data: ByteArray): Unit = backupErrors { documents.write(uri, data) }

    override fun readDocument(uri: String, maxBytes: Long): ByteArray = backupErrors { documents.read(uri, maxBytes) }

    override fun sealBackup(plain: ByteArray, passphrase: String): ByteArray =
        backupErrors { BackupCrypto.seal(plain, passphrase) }

    override fun openBackup(sealed: ByteArray, passphrase: String): ByteArray? =
        backupErrors { BackupCrypto.open(sealed, passphrase) }

    // ---- Model packs (Wave 3) ---------------------------------------------------------

    override fun importPack(uri: String): PackInfoMessage {
        val input = activity.contentResolver.openInputStream(Uri.parse(uri))
            ?: throw FlutterError("bad_format", "cannot open document", null)
        return try {
            input.use { PackStore.get(activity).install(it).toMessage() }
        } catch (e: PackException) {
            throw FlutterError(e.code, e.message, null)
        }
    }

    override fun deletePack(id: String) = PackStore.get(activity).delete(id)

    /** Maps [BackupException] to the FlutterError code Dart matches on. */
    private inline fun <T> backupErrors(block: () -> T): T = try {
        block()
    } catch (e: BackupException) {
        throw FlutterError(e.code, e.message, null)
    }
}
