// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.translate

import android.content.Context
import app.myna.keyboard.packs.PackStore

/**
 * Offline translation. Interface: orchestrator. Implementation: Wave 3-T (this folder).
 *
 * [translate] runs on a background thread (never the main thread) and may block. Keep at most one
 * model loaded. Never log [text] or the result.
 */
interface TranslationService {
    /** Throws [TranslationException] with code `no_pack` or `failed`. */
    fun translate(text: String, from: String, to: String): String

    fun release()
}

class TranslationException(val code: String, message: String) : Exception(message)

/** Wave 3-T replaces the body with the real engine. */
fun createTranslationService(context: Context, packs: PackStore): TranslationService = UnavailableTranslationService

private object UnavailableTranslationService : TranslationService {
    override fun translate(text: String, from: String, to: String): String =
        throw TranslationException("no_pack", "translation is not available yet")

    override fun release() {}
}
