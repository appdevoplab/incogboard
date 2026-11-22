// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.voice

import android.content.Context
import app.kosha.keyboard.bridge.VoiceEventMessage
import app.kosha.keyboard.bridge.VoiceRequestMessage
import app.kosha.keyboard.bridge.VoiceStartStatus
import app.kosha.keyboard.packs.PackStore

/**
 * Offline voice typing. Interface: orchestrator. Implementation: Wave 3-D (this folder).
 *
 * All calls arrive on the main thread. [start] returns once recording started or failed; events go
 * to [VoiceEvents] on the main thread, ending with exactly one `stopped`. Audio stays in memory and
 * buffers are zeroed after use. Never log recognised text.
 */
interface VoiceService {
    suspend fun start(request: VoiceRequestMessage, events: VoiceEvents): VoiceStartStatus

    /** Stop listening, finish the current utterance, then `stopped`. */
    fun stop()

    /** Stop and drop pending text, then `stopped`. */
    fun cancel()

    /** Free the model (keyboard hidden for a while, memory pressure, service destroyed). */
    fun release()
}

fun interface VoiceEvents {
    fun emit(event: VoiceEventMessage)
}

/** Offline voice typing with sherpa-onnx and Whisper voice packs (Wave 3-D, SherpaVoiceService.kt). */
fun createVoiceService(context: Context, packs: PackStore): VoiceService = newSherpaVoiceService(context, packs)
