// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.voice

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import com.k2fsa.sherpa.onnx.OfflineModelConfig
import com.k2fsa.sherpa.onnx.OfflineRecognizer
import com.k2fsa.sherpa.onnx.OfflineRecognizerConfig
import com.k2fsa.sherpa.onnx.OfflineWhisperModelConfig
import com.k2fsa.sherpa.onnx.SileroVadModelConfig
import com.k2fsa.sherpa.onnx.Vad
import com.k2fsa.sherpa.onnx.VadModelConfig
import java.io.File

/**
 * The real engine and microphone. OWNER: Wave 3-D. The JNI library (`libsherpa-onnx-jni.so`) binds to the
 * classes in `voice/sherpa/`. It loads `libonnxruntime.so` from the onnxruntime-android AAR; no second runtime.
 */

private const val SAMPLE_RATE = 16_000
private const val WHISPER_THREADS = 2

/** Loads Whisper and Silero VAD from a voice pack folder. [whisperCode] '' lets Whisper detect the language. */
internal fun loadSherpaEngine(dir: File, whisperCode: String): SpeechEngine {
    val recognizer = OfflineRecognizer(
        config = OfflineRecognizerConfig(
            modelConfig = OfflineModelConfig(
                whisper = OfflineWhisperModelConfig(
                    encoder = File(dir, "encoder.int8.onnx").path,
                    decoder = File(dir, "decoder.int8.onnx").path,
                    language = whisperCode,
                    task = "transcribe",
                ),
                tokens = File(dir, "tokens.txt").path,
                numThreads = WHISPER_THREADS,
                provider = "cpu",
            ),
        ),
    )
    val vad = try {
        Vad(
            config = VadModelConfig(
                sileroVadModelConfig = SileroVadModelConfig(
                    model = File(dir, "silero_vad.onnx").path,
                    threshold = 0.5f,
                    minSilenceDuration = 0.5f,
                    minSpeechDuration = 0.25f,
                    windowSize = 512,
                    maxSpeechDuration = 12f,
                ),
                sampleRate = SAMPLE_RATE,
                numThreads = 1,
                provider = "cpu",
            ),
        )
    } catch (e: Exception) {
        recognizer.release()
        throw e
    }
    return SherpaSpeechEngine(recognizer, vad)
}

internal class SherpaSpeechEngine(
    private val recognizer: OfflineRecognizer,
    private val vad: Vad,
) : SpeechEngine {
    override fun decode(samples: FloatArray): String {
        val stream = recognizer.createStream()
        try {
            stream.acceptWaveform(samples, SAMPLE_RATE)
            recognizer.decode(stream)
            return recognizer.getResult(stream).text
        } finally {
            stream.release()
        }
    }

    override fun acceptAudio(samples: FloatArray) = vad.acceptWaveform(samples)

    override fun isSpeaking(): Boolean = vad.isSpeechDetected()

    override fun nextSegment(): FloatArray? {
        if (vad.empty()) return null
        val segment = vad.front()
        vad.pop()
        return segment.samples
    }

    override fun flushAudio() = vad.flush()

    override fun resetAudio() = vad.reset()

    override fun release() {
        vad.release()
        recognizer.release()
    }
}

/** 16 kHz mono PCM16 from the voice-recognition source. Owned by the capture thread once started. */
internal class AudioRecordMicrophone : Microphone {
    private var record: AudioRecord? = null

    override fun start(): Boolean {
        val minBytes = AudioRecord.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        if (minBytes <= 0) return false
        val bufferBytes = maxOf(minBytes, SAMPLE_RATE / 2 * 2)
        val r = try {
            AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferBytes,
            )
        } catch (e: IllegalArgumentException) {
            return false
        } catch (e: SecurityException) {
            return false
        }
        if (r.state != AudioRecord.STATE_INITIALIZED) {
            r.release()
            return false
        }
        try {
            r.startRecording()
        } catch (e: IllegalStateException) {
            r.release()
            return false
        }
        if (r.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
            r.release()
            return false
        }
        record = r
        return true
    }

    override fun read(buffer: ShortArray): Int {
        val r = record ?: throw VoiceFailure("internal")
        val n = r.read(buffer, 0, buffer.size)
        return when {
            n >= 0 -> n
            n == AudioRecord.ERROR_DEAD_OBJECT -> throw VoiceFailure("audio_busy")
            else -> throw VoiceFailure("internal")
        }
    }

    override fun stop() {
        val r = record ?: return
        record = null
        try {
            r.stop()
        } catch (e: IllegalStateException) {
            // Already stopped.
        }
        r.release()
    }
}
