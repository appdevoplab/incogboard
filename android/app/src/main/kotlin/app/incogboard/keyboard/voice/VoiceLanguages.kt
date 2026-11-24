// SPDX-License-Identifier: GPL-3.0-or-later
package app.incogboard.keyboard.voice

import app.incogboard.keyboard.packs.InstalledPack
import app.incogboard.keyboard.packs.PackManifest

/**
 * IncogBoard language ids to Whisper language codes, and the pack lookup for voice. OWNER: Wave 3-D.
 *
 * Whisper rejects unknown codes with a fatal error in the native library (it exits the process), so
 * only codes from [WHISPER_CODES] ever reach it. An empty code means "detect the language".
 */
internal object VoiceLanguages {
    /** Codes Whisper's multilingual tokenizer knows and IncogBoard supports. */
    val WHISPER_CODES: Set<String> = setOf(
        "en", "es", "fr", "de", "pt", "id", "ru", "uk", "hi", "mr", "bn", "ta", "te", "ar", "ur",
    )

    /** Whisper code for a IncogBoard id ('pt-BR' gives 'pt'), or "" to let Whisper detect the language. */
    fun whisperCode(language: String?): String {
        if (language.isNullOrBlank()) return ""
        val code = language.substringBefore('-').lowercase()
        return if (code in WHISPER_CODES) code else ""
    }
}

/**
 * Picks the voice pack for a request: the pack named by [packId] when it is installed (a named pack that
 * was deleted, or an old setting, falls back to the automatic choice), else the first installed voice
 * pack that covers [language], else (when [language] is null) the first installed voice pack.
 * [open] and [list] are PackStore's `open` and `list`; null when nothing fits.
 */
internal fun resolveVoicePack(
    packId: String,
    language: String?,
    open: (String) -> InstalledPack?,
    list: () -> List<InstalledPack>,
): InstalledPack? {
    val voice = { p: InstalledPack -> p.manifest.kind == PackManifest.KIND_VOICE }
    if (packId.isNotEmpty()) open(packId)?.takeIf(voice)?.let { return it }
    val voicePacks = list().filter(voice)
    if (language.isNullOrBlank()) return voicePacks.firstOrNull()
    return voicePacks.firstOrNull { it.manifest.languages.contains(language) }
}
