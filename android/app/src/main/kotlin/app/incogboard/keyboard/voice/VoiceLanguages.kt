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
        "en", "es", "fr", "de", "pt", "id", "ru", "uk", "hi", "mr", "bn", "ta", "te", "ar", "ur", "tl",
    )

    /** IncogBoard ids whose Whisper code differs: Filipino is Whisper's Tagalog. */
    private val ALIASES = mapOf("fil" to "tl")

    /**
     * Languages added after the published voice pack was signed: every multilingual Whisper pack understands
     * them, but older pack manifests do not list them.
     */
    val ANY_MULTILINGUAL_PACK: Set<String> = setOf("fil")

    /** Whisper code for a IncogBoard id ('pt-BR' gives 'pt'), or "" to let Whisper detect the language. */
    fun whisperCode(language: String?): String {
        if (language.isNullOrBlank()) return ""
        val base = language.substringBefore('-').lowercase()
        val code = ALIASES[base] ?: base
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
    // A chosen pack is used for its own languages (and for Auto); a single-language pack such as Parakeet
    // English must not transcribe Hindi as English when the keyboard language is Hindi.
    val fits = { p: InstalledPack ->
        language.isNullOrBlank() || p.manifest.languages.contains(language) ||
            (isMultilingualWhisper(p) && VoiceLanguages.whisperCode(language).isNotEmpty())
    }
    if (packId.isNotEmpty()) open(packId)?.takeIf { voice(it) && fits(it) }?.let { return it }
    val voicePacks = list().filter(voice)
    if (language.isNullOrBlank()) return voicePacks.firstOrNull()
    voicePacks.firstOrNull { it.manifest.languages.contains(language) }?.let { return it }
    if (language !in VoiceLanguages.ANY_MULTILINGUAL_PACK) return null
    return voicePacks.firstOrNull(::isMultilingualWhisper)
}

private fun isMultilingualWhisper(p: InstalledPack): Boolean =
    p.manifest.engine == VoiceEngines.WHISPER && p.manifest.languages.size > 1
