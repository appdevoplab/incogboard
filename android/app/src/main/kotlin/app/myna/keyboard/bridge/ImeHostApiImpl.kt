// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.bridge

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PersistableBundle
import android.os.SystemClock
import android.util.Log
import android.view.KeyCharacterMap
import android.view.KeyEvent
import android.view.WindowManager
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import app.myna.keyboard.SettingsActivity
import app.myna.keyboard.ime.ClipReader
import app.myna.keyboard.ime.MynaImeService

/** Dart -> Kotlin calls for the keyboard engine. Runs on the main thread. */
internal class ImeHostApiImpl(private val service: MynaImeService) : ImeHostApi {

    private val ic: InputConnection? get() = service.currentInputConnection
    private val clipboard by lazy { service.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager }
    private val imm by lazy { service.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager }

    /**
     * Runs one InputConnection call. A missing connection (no focused field) or any exception thrown by
     * the editor's process (dead object, bad state) yields [fallback] instead of crashing the keyboard.
     * Only the exception type is logged, never text.
     */
    private inline fun <T : Any> guard(fallback: T, call: (InputConnection) -> T?): T {
        val c = ic ?: return fallback
        return try {
            call(c) ?: fallback
        } catch (e: Exception) {
            Log.w(TAG, "InputConnection call failed: ${e.javaClass.simpleName}")
            fallback
        }
    }

    /** Like [guard] for calls whose null result is meaningful. */
    private inline fun <T : Any> guardNullable(call: (InputConnection) -> T?): T? {
        val c = ic ?: return null
        return try {
            call(c)
        } catch (e: Exception) {
            Log.w(TAG, "InputConnection call failed: ${e.javaClass.simpleName}")
            null
        }
    }

    /** Dart sends 64-bit ints: never let one wrap around when narrowing to Int. */
    private fun Long.toIntClamped(max: Int = Int.MAX_VALUE): Int = coerceIn(0L, max.toLong()).toInt()

    // ---- InputConnection --------------------------------------------------------

    override fun commitText(text: String, newCursorPosition: Long) =
        guard(false) { it.commitText(text, newCursorPosition.coerceIn(-MAX_CURSOR, MAX_CURSOR).toInt()) }

    override fun setComposingText(text: String, newCursorPosition: Long) =
        guard(false) { it.setComposingText(text, newCursorPosition.coerceIn(-MAX_CURSOR, MAX_CURSOR).toInt()) }

    override fun setComposingRegion(start: Long, end: Long) =
        guard(false) { it.setComposingRegion(start.toIntClamped(), end.toIntClamped()) }

    override fun finishComposingText() = guard(false) { it.finishComposingText() }

    override fun deleteSurroundingText(beforeLength: Long, afterLength: Long) =
        guard(false) { it.deleteSurroundingText(beforeLength.toIntClamped(), afterLength.toIntClamped()) }

    override fun deleteSurroundingTextInCodePoints(beforeLength: Long, afterLength: Long) =
        guard(false) { it.deleteSurroundingTextInCodePoints(beforeLength.toIntClamped(), afterLength.toIntClamped()) }

    override fun sendDownUpKeyEvent(keyCode: Long, metaState: Long) = guard(false) { c ->
        val now = SystemClock.uptimeMillis()
        val flags = KeyEvent.FLAG_SOFT_KEYBOARD or KeyEvent.FLAG_KEEP_TOUCH_MODE
        val down = KeyEvent(
            now, now, KeyEvent.ACTION_DOWN, keyCode.toInt(), 0, metaState.toInt(),
            KeyCharacterMap.VIRTUAL_KEYBOARD, 0, flags,
        )
        val sentDown = c.sendKeyEvent(down)
        val sentUp = c.sendKeyEvent(KeyEvent.changeAction(down, KeyEvent.ACTION_UP))
        sentDown && sentUp
    }

    override fun performEditorAction(actionId: Long) = guard(false) { it.performEditorAction(actionId.toInt()) }

    override fun performContextMenuAction(action: ContextMenuAction): Boolean {
        val id = when (action) {
            ContextMenuAction.SELECT_ALL -> android.R.id.selectAll
            ContextMenuAction.CUT -> android.R.id.cut
            ContextMenuAction.COPY -> android.R.id.copy
            ContextMenuAction.PASTE -> android.R.id.paste
            ContextMenuAction.PASTE_AS_PLAIN_TEXT -> android.R.id.pasteAsPlainText
            ContextMenuAction.UNDO -> android.R.id.undo
            ContextMenuAction.REDO -> android.R.id.redo
            ContextMenuAction.START_SELECTING_TEXT -> android.R.id.startSelectingText
            ContextMenuAction.STOP_SELECTING_TEXT -> android.R.id.stopSelectingText
        }
        return guard(false) { it.performContextMenuAction(id) }
    }

    override fun setSelection(start: Long, end: Long) =
        guard(false) { it.setSelection(start.toIntClamped(), end.toIntClamped()) }

    override fun getTextBeforeCursor(length: Long): String? =
        guardNullable { it.getTextBeforeCursor(length.toIntClamped(MAX_QUERY), 0)?.toString() }

    override fun getTextAfterCursor(length: Long): String? =
        guardNullable { it.getTextAfterCursor(length.toIntClamped(MAX_QUERY), 0)?.toString() }

    override fun getSelectedText(): String? = guardNullable { it.getSelectedText(0)?.toString() }

    override fun getSurroundingText(beforeLength: Long, afterLength: Long): SurroundingTextMessage? =
        guardNullable { c ->
            val before = beforeLength.toIntClamped(MAX_QUERY)
            val after = afterLength.toIntClamped(MAX_QUERY)
            if (Build.VERSION.SDK_INT >= 31) {
                val s = c.getSurroundingText(before, after, 0) ?: return@guardNullable null
                SurroundingTextMessage(
                    s.text.toString(), s.selectionStart.toLong(), s.selectionEnd.toLong(), s.offset.toLong(),
                )
            } else {
                val textBefore = c.getTextBeforeCursor(before, 0)?.toString() ?: return@guardNullable null
                val selected = c.getSelectedText(0)?.toString() ?: ""
                val textAfter = c.getTextAfterCursor(after, 0)?.toString() ?: ""
                SurroundingTextMessage(
                    textBefore + selected + textAfter,
                    textBefore.length.toLong(),
                    (textBefore.length + selected.length).toLong(),
                    -1,
                )
            }
        }

    override fun getCursorCapsMode(reqModes: Long): Long =
        guard(0) { it.getCursorCapsMode(reqModes.toInt()) }.toLong()

    override fun beginBatchEdit() = guard(false) { it.beginBatchEdit() }

    override fun endBatchEdit() = guard(false) { it.endBatchEdit() }

    // ---- Keyboard window --------------------------------------------------------

    override fun setWindowLayout(layout: WindowLayoutMessage) = service.applyWindowLayout(layout)

    override fun setSecureWindow(secure: Boolean) {
        val w = service.window?.window ?: return
        if (secure) w.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        else w.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun hideKeyboard() = service.requestHideSelf(0)

    override fun switchToPreviousInputMethod() =
        Build.VERSION.SDK_INT >= 28 && service.switchToPreviousInputMethod()

    override fun switchToNextInputMethod(onlyCurrentIme: Boolean) =
        Build.VERSION.SDK_INT >= 28 && service.switchToNextInputMethod(onlyCurrentIme)

    override fun showInputMethodPicker() = imm.showInputMethodPicker()

    override fun openSettings(route: String?) {
        val intent = Intent(service, SettingsActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        if (route != null) intent.putExtra(EXTRA_ROUTE, route)
        service.startActivity(intent)
    }

    override fun setInlineSuggestionsArea(area: RectMessage?) = service.setInlineSuggestionsArea(area)

    // ---- Feedback ---------------------------------------------------------------

    override fun setFeedbackConfig(config: FeedbackConfigMessage) = service.feedback.configure(config)

    override fun performHaptic(kind: HapticKind) = service.feedback.haptic(kind, service.feedbackView())

    override fun playKeySound(kind: KeySoundKind) = service.feedback.sound(kind)

    // ---- Clipboard --------------------------------------------------------------

    /** Text clips up to [ClipReader.MAX_CHARS] characters; anything else reads as null. */
    override fun getPrimaryClip(): ClipMessage? = try {
        ClipReader.read(clipboard.primaryClip)
    } catch (e: Exception) {
        Log.w(TAG, "clipboard read failed: ${e.javaClass.simpleName}")
        null
    }

    override fun setPrimaryClip(text: String, sensitive: Boolean) {
        try {
            val clip = ClipData.newPlainText("Myna", text)
            if (sensitive) {
                clip.description.extras = PersistableBundle().apply {
                    putBoolean("android.content.extra.IS_SENSITIVE", true)
                }
            }
            clipboard.setPrimaryClip(clip)
        } catch (e: Exception) {
            Log.w(TAG, "clipboard write failed: ${e.javaClass.simpleName}")
        }
    }

    override fun clearPrimaryClip() {
        try {
            if (Build.VERSION.SDK_INT >= 28) clipboard.clearPrimaryClip()
        } catch (e: Exception) {
            Log.w(TAG, "clipboard clear failed: ${e.javaClass.simpleName}")
        }
    }

    // ---- State sync -------------------------------------------------------------

    override fun getWindowMetrics() = service.windowMetrics()

    override fun getCurrentEditorInfo() = service.currentInputEditorInfo?.toMessage()

    override fun isInputViewShown() = service.isInputViewShown

    companion object {
        const val EXTRA_ROUTE = "app.myna.keyboard.ROUTE"
        private const val TAG = "MynaIme"
        private const val MAX_QUERY = 100_000
        private const val MAX_CURSOR = 1_000_000L
    }
}
