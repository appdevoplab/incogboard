// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.bridge

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.PersistableBundle
import android.os.SystemClock
import android.view.HapticFeedbackConstants
import android.view.KeyCharacterMap
import android.view.KeyEvent
import android.view.WindowManager
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import app.myna.keyboard.SettingsActivity
import app.myna.keyboard.ime.MynaImeService

/** Dart -> Kotlin calls for the keyboard engine. Runs on the main thread. */
internal class ImeHostApiImpl(private val service: MynaImeService) : ImeHostApi {

    private val ic: InputConnection? get() = service.currentInputConnection
    private var feedback = FeedbackConfigMessage(
        hapticsEnabled = true, hapticStrength = 0.5, soundsEnabled = false, soundVolume = -1.0,
    )
    private val audio by lazy { service.getSystemService(Context.AUDIO_SERVICE) as AudioManager }
    private val clipboard by lazy { service.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager }
    private val imm by lazy { service.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager }

    // ---- InputConnection --------------------------------------------------------

    override fun commitText(text: String, newCursorPosition: Long) =
        ic?.commitText(text, newCursorPosition.toInt()) ?: false

    override fun setComposingText(text: String, newCursorPosition: Long) =
        ic?.setComposingText(text, newCursorPosition.toInt()) ?: false

    override fun setComposingRegion(start: Long, end: Long) =
        ic?.setComposingRegion(start.toInt(), end.toInt()) ?: false

    override fun finishComposingText() = ic?.finishComposingText() ?: false

    override fun deleteSurroundingText(beforeLength: Long, afterLength: Long) =
        ic?.deleteSurroundingText(beforeLength.toInt(), afterLength.toInt()) ?: false

    override fun deleteSurroundingTextInCodePoints(beforeLength: Long, afterLength: Long) =
        ic?.deleteSurroundingTextInCodePoints(beforeLength.toInt(), afterLength.toInt()) ?: false

    override fun sendDownUpKeyEvent(keyCode: Long, metaState: Long): Boolean {
        val c = ic ?: return false
        val now = SystemClock.uptimeMillis()
        val flags = KeyEvent.FLAG_SOFT_KEYBOARD or KeyEvent.FLAG_KEEP_TOUCH_MODE
        val down = KeyEvent(
            now, now, KeyEvent.ACTION_DOWN, keyCode.toInt(), 0, metaState.toInt(),
            KeyCharacterMap.VIRTUAL_KEYBOARD, 0, flags,
        )
        val sentDown = c.sendKeyEvent(down)
        val sentUp = c.sendKeyEvent(KeyEvent.changeAction(down, KeyEvent.ACTION_UP))
        return sentDown && sentUp
    }

    override fun performEditorAction(actionId: Long) = ic?.performEditorAction(actionId.toInt()) ?: false

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
        return ic?.performContextMenuAction(id) ?: false
    }

    override fun setSelection(start: Long, end: Long) = ic?.setSelection(start.toInt(), end.toInt()) ?: false

    override fun getTextBeforeCursor(length: Long) = ic?.getTextBeforeCursor(length.toInt(), 0)?.toString()

    override fun getTextAfterCursor(length: Long) = ic?.getTextAfterCursor(length.toInt(), 0)?.toString()

    override fun getSelectedText() = ic?.getSelectedText(0)?.toString()

    override fun getSurroundingText(beforeLength: Long, afterLength: Long): SurroundingTextMessage? {
        val c = ic ?: return null
        if (Build.VERSION.SDK_INT >= 31) {
            val s = c.getSurroundingText(beforeLength.toInt(), afterLength.toInt(), 0) ?: return null
            return SurroundingTextMessage(
                s.text.toString(), s.selectionStart.toLong(), s.selectionEnd.toLong(), s.offset.toLong(),
            )
        }
        val before = c.getTextBeforeCursor(beforeLength.toInt(), 0)?.toString() ?: return null
        val selected = c.getSelectedText(0)?.toString() ?: ""
        val after = c.getTextAfterCursor(afterLength.toInt(), 0)?.toString() ?: ""
        return SurroundingTextMessage(
            before + selected + after, before.length.toLong(), (before.length + selected.length).toLong(), -1,
        )
    }

    override fun getCursorCapsMode(reqModes: Long) = (ic?.getCursorCapsMode(reqModes.toInt()) ?: 0).toLong()

    override fun beginBatchEdit() = ic?.beginBatchEdit() ?: false

    override fun endBatchEdit() = ic?.endBatchEdit() ?: false

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

    override fun setInlineSuggestionsArea(area: RectMessage?) {
        // Implemented in Wave 1 (Android platform layer): overlay inline autofill views here.
    }

    // ---- Feedback ---------------------------------------------------------------

    override fun setFeedbackConfig(config: FeedbackConfigMessage) {
        feedback = config
    }

    override fun performHaptic(kind: HapticKind) {
        if (!feedback.hapticsEnabled) return
        val constant = when (kind) {
            HapticKind.KEY_LONG_PRESS -> HapticFeedbackConstants.LONG_PRESS
            HapticKind.ERROR -> if (Build.VERSION.SDK_INT >= 30) HapticFeedbackConstants.REJECT else HapticFeedbackConstants.LONG_PRESS
            HapticKind.TOGGLE -> if (Build.VERSION.SDK_INT >= 34) HapticFeedbackConstants.TOGGLE_ON else HapticFeedbackConstants.KEYBOARD_TAP
            else -> HapticFeedbackConstants.KEYBOARD_TAP
        }
        service.feedbackView()?.performHapticFeedback(constant)
    }

    override fun playKeySound(kind: KeySoundKind) {
        if (!feedback.soundsEnabled) return
        val effect = when (kind) {
            KeySoundKind.SPACE -> AudioManager.FX_KEYPRESS_SPACEBAR
            KeySoundKind.DELETE -> AudioManager.FX_KEYPRESS_DELETE
            KeySoundKind.ENTER -> AudioManager.FX_KEYPRESS_RETURN
            KeySoundKind.STANDARD -> AudioManager.FX_KEYPRESS_STANDARD
        }
        audio.playSoundEffect(effect, feedback.soundVolume.toFloat())
    }

    // ---- Clipboard --------------------------------------------------------------

    override fun getPrimaryClip(): ClipMessage? {
        val clip = clipboard.primaryClip ?: return null
        if (clip.itemCount == 0) return null
        val text = clip.getItemAt(0).coerceToText(service)?.toString() ?: return null
        val desc = clip.description
        val sensitive = Build.VERSION.SDK_INT >= 33 &&
            desc.extras?.getBoolean(ClipDescription.EXTRA_IS_SENSITIVE) == true
        return ClipMessage(text, desc.timestamp, sensitive)
    }

    override fun setPrimaryClip(text: String, sensitive: Boolean) {
        val clip = ClipData.newPlainText("Myna", text)
        if (sensitive) {
            clip.description.extras = PersistableBundle().apply {
                putBoolean("android.content.extra.IS_SENSITIVE", true)
            }
        }
        clipboard.setPrimaryClip(clip)
    }

    override fun clearPrimaryClip() {
        if (Build.VERSION.SDK_INT >= 28) clipboard.clearPrimaryClip()
    }

    // ---- State sync -------------------------------------------------------------

    override fun getWindowMetrics() = service.windowMetrics()

    override fun getCurrentEditorInfo() = service.currentInputEditorInfo?.toMessage()

    override fun isInputViewShown() = service.isInputViewShown

    companion object {
        const val EXTRA_ROUTE = "app.myna.keyboard.ROUTE"
    }
}
