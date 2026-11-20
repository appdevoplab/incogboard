// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.security

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import java.io.File
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * Encrypted blob storage for learned words, n-grams, clipboard history and
 * personal shortcuts.
 *
 * - AES-256-GCM with a non-exportable Android Keystore key (StrongBox when available).
 * - Files live in noBackupFilesDir (never backed up; backups are disabled anyway).
 * - Writes are atomic (temp file + rename) and the previous good copy is kept as `.bak`.
 *
 * File format: [1 byte version=1][1 byte iv length][iv][ciphertext+tag].
 */
class SecureStore(context: Context) {

    private val dir = File(context.noBackupFilesDir, "secure").apply { mkdirs() }

    @Synchronized
    fun write(name: String, data: ByteArray) {
        val target = fileFor(name)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key())
        val iv = cipher.iv
        val sealed = cipher.doFinal(data)
        val tmp = File(dir, "$name.tmp")
        tmp.outputStream().use { out ->
            out.write(FORMAT_VERSION)
            out.write(iv.size)
            out.write(iv)
            out.write(sealed)
            out.fd.sync()
        }
        if (target.exists()) target.copyTo(File(dir, "$name.bak"), overwrite = true)
        if (!tmp.renameTo(target)) {
            target.delete()
            check(tmp.renameTo(target)) { "rename failed" }
        }
    }

    @Synchronized
    fun read(name: String): ByteArray? {
        val target = fileFor(name)
        return decrypt(target) ?: decrypt(File(dir, "$name.bak"))
    }

    @Synchronized
    fun delete(name: String) {
        fileFor(name).delete()
        File(dir, "$name.bak").delete()
        File(dir, "$name.tmp").delete()
    }

    /** Deletes every blob and destroys the key, so stale copies can never be decrypted. */
    @Synchronized
    fun wipeAll() {
        dir.listFiles()?.forEach { it.delete() }
        runCatching { keyStore().deleteEntry(KEY_ALIAS) }
    }

    private fun decrypt(file: File): ByteArray? {
        if (!file.exists()) return null
        return runCatching {
            val bytes = file.readBytes()
            require(bytes.size > 2 && bytes[0].toInt() == FORMAT_VERSION)
            val ivLen = bytes[1].toInt()
            val iv = bytes.copyOfRange(2, 2 + ivLen)
            val sealed = bytes.copyOfRange(2 + ivLen, bytes.size)
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, iv))
            cipher.doFinal(sealed)
        }.getOrNull()
    }

    private fun fileFor(name: String): File {
        require(NAME.matches(name)) { "invalid secure-store name" }
        return File(dir, "$name.bin")
    }

    private fun keyStore() = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }

    private fun key(): SecretKey {
        (keyStore().getEntry(KEY_ALIAS, null) as? KeyStore.SecretKeyEntry)?.let { return it.secretKey }
        return try {
            generateKey(strongBox = Build.VERSION.SDK_INT >= 28)
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= 28 && e is StrongBoxUnavailableException) generateKey(strongBox = false)
            else throw e
        }
    }

    private fun generateKey(strongBox: Boolean): SecretKey {
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setRandomizedEncryptionRequired(true)
            .apply {
                if (Build.VERSION.SDK_INT >= 28) {
                    setIsStrongBoxBacked(strongBox)
                    // Typing data is only readable while the phone is unlocked.
                    setUnlockedDeviceRequired(true)
                }
            }
            .build()
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        generator.init(spec)
        return generator.generateKey()
    }

    private companion object {
        const val ANDROID_KEYSTORE = "AndroidKeyStore"
        const val KEY_ALIAS = "myna.secure_store.v1"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val FORMAT_VERSION = 1
        val NAME = Regex("^[a-z0-9_.-]{1,64}$")
    }
}
