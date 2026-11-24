// SPDX-License-Identifier: GPL-3.0-or-later
package app.incogboard.keyboard.voice

import app.incogboard.keyboard.bridge.VoiceEventKind
import app.incogboard.keyboard.bridge.VoiceEventMessage
import app.incogboard.keyboard.bridge.VoiceRequestMessage
import app.incogboard.keyboard.bridge.VoiceStartStatus
import app.incogboard.keyboard.packs.InstalledPack
import app.incogboard.keyboard.packs.PackManifest
import java.io.File
import java.util.concurrent.ConcurrentLinkedQueue
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SherpaVoiceServiceTest {
    private companion object {
        val voicePack: InstalledPack = InstalledPack(
        manifest = PackManifest(
            id = "voice-whisper-base",
            kind = "voice",
            name = "Whisper base",
            version = 1,
            languages = listOf("en", "pt-BR", "hi"),
            engine = "sherpa-onnx-whisper",
            license = "MIT",
            files = emptyList(),
        ),
        dir = File("/unused"),
        sizeBytes = 0,
    )
    }

    private class Harness(
        val packs: List<InstalledPack> = listOf(voicePack),
        val micStartOk: Boolean = true,
        val micFrames: List<ShortArray> = frames(40),
        val engine: FakeEngine = FakeEngine(speechChunks = 0),
    ) {
        val main = InlineMainThread()
        val loads = ConcurrentLinkedQueue<String>()
        val mics = ConcurrentLinkedQueue<FakeMicrophone>()
        val log = mutableListOf<String>()

        val service = SherpaVoiceService(
            VoiceDeps(
                openPack = { id -> packs.firstOrNull { it.manifest.id == id } },
                listPacks = { packs },
                loadEngine = { _, code ->
                    loads.add(code)
                    engine
                },
                newMicrophone = {
                    FakeMicrophone(micFrames, startOk = micStartOk).also { mics.add(it) }
                },
                main = main,
                clock = Clock { System.currentTimeMillis() },
                log = { message -> log.add(message) },
            ),
        )
    }

    private class Collected {
        val events = ConcurrentLinkedQueue<VoiceEventMessage>()
        val emit = VoiceEvents { events.add(it) }
        fun kinds() = events.map { it.kind }
    }

    private fun request(language: String? = "pt-BR", autoDetect: Boolean = false, packId: String = "") =
        VoiceRequestMessage(language = language, packId = packId, autoDetect = autoDetect)

    private fun awaitStopped(collected: Collected) {
        val end = System.currentTimeMillis() + 10_000
        while (collected.kinds().none { it == VoiceEventKind.STOPPED }) {
            if (System.currentTimeMillis() > end) throw AssertionError("no stopped event")
            Thread.sleep(2)
        }
    }

    @Test
    fun noVoicePackReturnsNoModelAndLoadsNothing() = runBlocking {
        val h = Harness(packs = emptyList())
        assertEquals(VoiceStartStatus.NO_MODEL, h.service.start(request(), Collected().emit))
        assertTrue(h.loads.isEmpty())
    }

    @Test
    fun brazilianPortugueseLoadsWhisperPortuguese() = runBlocking {
        val h = Harness()
        val collected = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("pt-BR"), collected.emit))
        h.service.stop()
        awaitStopped(collected)
        assertEquals(listOf("pt"), h.loads.toList())
    }

    @Test
    fun autoDetectLoadsWithoutALanguage() = runBlocking {
        val h = Harness()
        val collected = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("hi", autoDetect = true), collected.emit))
        h.service.stop()
        awaitStopped(collected)
        assertEquals(listOf(""), h.loads.toList())
    }

    @Test
    fun micBusyEmitsAudioBusyThenStoppedAndReturnsBusy() = runBlocking {
        val h = Harness(micStartOk = false)
        val collected = Collected()
        assertEquals(VoiceStartStatus.BUSY, h.service.start(request("en"), collected.emit))
        assertEquals(
            listOf(VoiceEventKind.ERROR, VoiceEventKind.STOPPED),
            collected.kinds(),
        )
        assertEquals("audio_busy", collected.events.first().errorCode)
    }

    @Test
    fun secondStartWhileRecordingIsBusy() = runBlocking {
        val h = Harness(micFrames = frames(200))
        val collected = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("en"), collected.emit))
        assertEquals(VoiceStartStatus.BUSY, h.service.start(request("en"), Collected().emit))
        h.service.cancel()
        awaitStopped(collected)
    }

    @Test
    fun stopEndsWithExactlyOneStoppedAndTheMicIsReleased() = runBlocking {
        val h = Harness(engine = FakeEngine(speechChunks = 2, text = "turn on the light"))
        val collected = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("en"), collected.emit))
        // Stop only once the detector has seen the speech and its segment is ready.
        while (h.engine.accepted.get() < 3) Thread.sleep(2)
        h.service.stop()
        awaitStopped(collected)
        Thread.sleep(20)
        assertEquals(1, collected.kinds().count { it == VoiceEventKind.STOPPED })
        assertTrue(collected.events.any { it.kind == VoiceEventKind.FINAL_TEXT && it.text == "turn on the light" })
        assertTrue(h.mics.single().stopped)
    }

    @Test
    fun cancelRightAfterStartStillEndsTheSession() = runBlocking {
        val h = Harness(micFrames = frames(400))
        val collected = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("en"), collected.emit))
        // A cancel right after start: the session ends with a stopped event and no text.
        h.service.cancel()
        awaitStopped(collected)
        assertTrue(collected.events.none { it.kind == VoiceEventKind.FINAL_TEXT })
    }

    @Test
    fun releaseAfterASessionUnloadsTheEngine() = runBlocking {
        val engine = FakeEngine(speechChunks = 0)
        val h = Harness(engine = engine)
        val collected = Collected()
        h.service.start(request("en"), collected.emit)
        h.service.release()
        awaitStopped(collected)
        Thread.sleep(20)
        assertTrue(engine.released)
    }

    @Test
    fun engineStaysWarmBetweenSessionsAndIsReleasedAfterIdle() = runBlocking {
        val engine = FakeEngine(speechChunks = 0)
        val h = Harness(engine = engine)
        val first = Collected()
        h.service.start(request("en"), first.emit)
        h.service.stop()
        awaitStopped(first)
        Thread.sleep(20)
        assertTrue(!engine.released)

        val second = Collected()
        assertEquals(VoiceStartStatus.STARTED, h.service.start(request("en"), second.emit))
        assertEquals(1, h.loads.size)
        h.service.stop()
        awaitStopped(second)
        Thread.sleep(20)

        // The idle timer runs on the main thread: fire it.
        h.main.delayed.forEach { (_, block) -> block() }
        assertTrue(engine.released)
    }
}
