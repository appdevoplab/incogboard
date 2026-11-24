// SPDX-License-Identifier: GPL-3.0-or-later
package app.incogboard.keyboard.bridge

import app.incogboard.keyboard.packs.OfferStatus
import app.incogboard.keyboard.packs.PackCheck
import app.incogboard.keyboard.packs.PackOffer
import org.junit.Assert.assertEquals
import org.junit.Test

/** The pack maintenance messages carry exactly what the store and the pack checker report. */
class PackMessagesTest {
    @Test
    fun checkKeepsCounts() {
        val m = PackCheck("translate-en-es", manifestOk = true, missingFiles = 2, damagedFiles = 3).toMessage()
        assertEquals("translate-en-es", m.id)
        assertEquals(true, m.manifestOk)
        assertEquals(2L, m.missingFiles)
        assertEquals(3L, m.damagedFiles)
    }

    @Test
    fun everyOfferStatusHasItsMessageStatus() {
        for (status in OfferStatus.values()) {
            val m = PackOffer("dict-ja-mozc", "Japanese", 7L, status).toMessage()
            assertEquals(status.name, m.status.name)
            assertEquals(7L, m.sizeBytes)
        }
    }
}
