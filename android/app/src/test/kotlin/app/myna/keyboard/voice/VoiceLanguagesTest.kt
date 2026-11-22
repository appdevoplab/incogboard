// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.voice

import app.myna.keyboard.packs.InstalledPack
import app.myna.keyboard.packs.PackManifest
import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Test

class VoiceLanguagesTest {
    @Test
    fun regionalIdsMapToTheWhisperBaseCode() {
        assertEquals("pt", VoiceLanguages.whisperCode("pt-BR"))
        assertEquals("pt", VoiceLanguages.whisperCode("pt-PT"))
        assertEquals("en", VoiceLanguages.whisperCode("en"))
        assertEquals("hi", VoiceLanguages.whisperCode("hi"))
        assertEquals("ur", VoiceLanguages.whisperCode("ur"))
    }

    @Test
    fun unknownOrMissingLanguagesLetWhisperDetect() {
        assertEquals("", VoiceLanguages.whisperCode(null))
        assertEquals("", VoiceLanguages.whisperCode(""))
        assertEquals("", VoiceLanguages.whisperCode("   "))
        // Never pass an unknown code to Whisper: the native side exits the process on one.
        assertEquals("", VoiceLanguages.whisperCode("zz"))
        assertEquals("", VoiceLanguages.whisperCode("zh-CN"))
    }

    @Test
    fun everyCodeIsOneWhisperKnows() {
        val expected = setOf("en", "es", "fr", "de", "pt", "id", "ru", "uk", "hi", "mr", "bn", "ta", "te", "ar", "ur")
        assertEquals(expected, VoiceLanguages.WHISPER_CODES)
    }

    private fun pack(id: String, kind: String, languages: List<String>) = InstalledPack(
        manifest = PackManifest(
            id = id,
            kind = kind,
            name = id,
            version = 1,
            languages = languages,
            engine = "sherpa-onnx-whisper",
            license = "MIT",
            files = emptyList(),
        ),
        dir = File("."),
        sizeBytes = 0,
    )

    private val base = pack("voice-whisper-base", "voice", listOf("en", "pt-BR", "hi"))
    private val small = pack("voice-whisper-small", "voice", listOf("en", "pt-BR", "hi", "ar"))
    private val translation = pack("translate-en-es", "translation", listOf("en", "es"))
    private val all = listOf(translation, base, small)

    private fun resolve(packId: String, language: String?, installed: List<InstalledPack> = all) = resolveVoicePack(
        packId = packId,
        language = language,
        open = { id -> installed.firstOrNull { it.manifest.id == id } },
        list = { installed },
    )

    @Test
    fun namedPackWinsWhenItIsAVoicePack() {
        assertSame(small, resolve("voice-whisper-small", "en"))
    }

    @Test
    fun aTranslationPackIsNeverUsedForVoice() {
        assertNull(resolve("translate-en-es", "en"))
    }

    @Test
    fun firstVoicePackCoveringTheLanguageIsChosen() {
        assertSame(base, resolve("", "hi"))
        assertSame(small, resolve("", "ar"))
        assertNull(resolve("", "ur"))
    }

    @Test
    fun withoutLanguageTheFirstVoicePackIsUsed() {
        assertSame(base, resolve("", null))
        assertNull(resolve("", null, listOf(translation)))
    }

    @Test
    fun noVoicePackMeansNoModel() {
        assertNull(resolve("", "en", emptyList()))
        assertNull(resolve("missing", "en"))
    }
}
