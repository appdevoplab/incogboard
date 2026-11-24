// SPDX-License-Identifier: GPL-3.0-or-later
package app.incogboard.keyboard.packs

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PackDownloadsTest {
    @Test
    fun publishedPackFileNamesBecomeReleaseLinks() {
        assertEquals(
            "https://github.com/appdevoplab/incogboard/releases/latest/download/voice-whisper-base.koshapack",
            PackDownloads.urlFor("voice-whisper-base.koshapack"),
        )
    }

    @Test
    fun anythingElseIsRefused() {
        for (bad in listOf(
            "",
            "voice.zip",
            "../voice.koshapack",
            "a/b.koshapack",
            "https://example.com/x.koshapack",
            "Voice.koshapack",
            "voice.koshapack?x=1",
            "-voice.koshapack",
        )) {
            assertNull(bad, PackDownloads.urlFor(bad))
        }
    }
}
