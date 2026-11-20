// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.ime

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.inputmethodservice.InputMethodService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.WindowInsets
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import android.widget.TextView
import app.myna.keyboard.MynaApplication
import app.myna.keyboard.bridge.EngineRole
import app.myna.keyboard.bridge.ImeFlutterApi
import app.myna.keyboard.bridge.ImeHostApi
import app.myna.keyboard.bridge.ImeHostApiImpl
import app.myna.keyboard.bridge.PlatformHostApi
import app.myna.keyboard.bridge.PlatformHostApiImpl
import app.myna.keyboard.bridge.SelectionMessage
import app.myna.keyboard.bridge.SettingsBus
import app.myna.keyboard.bridge.WindowLayoutMessage
import app.myna.keyboard.bridge.WindowMetricsMessage
import app.myna.keyboard.bridge.WindowMode
import app.myna.keyboard.bridge.isNightMode
import app.myna.keyboard.bridge.toMessage
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import kotlin.math.roundToInt

/**
 * Thin Kotlin shell around the Dart keyboard (entrypoint `keyboardMain`).
 *
 * Responsibilities: own the Flutter engine, size the input view, forward IME
 * lifecycle events to Dart, and keep a native fallback so the user can always
 * switch keyboards even if Flutter fails to draw.
 */
class MynaImeService : InputMethodService() {

    private var engine: FlutterEngine? = null
    private var flutterView: FlutterView? = null
    private var root: KeyboardContainer? = null
    private var fallback: View? = null
    private var firstFrameShown = false
    private val main = Handler(Looper.getMainLooper())

    internal var flutterApi: ImeFlutterApi? = null
        private set

    /** Total input-view height requested by Dart (dp), including the bottom inset. */
    private var contentHeightDp = DEFAULT_CONTENT_HEIGHT_DP
    internal var navBarInsetPx = 0
        private set
    internal var windowMode = WindowMode.DOCKED
        private set

    private val fallbackCheck = Runnable {
        if (!firstFrameShown) fallback?.visibility = View.VISIBLE
    }

    override fun onCreate() {
        super.onCreate()
        // Creating the group initializes FlutterLoader; it must exist before
        // findAppBundlePath() is called.
        val group = (application as MynaApplication).engineGroup
        val entrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            "keyboardMain",
        )
        // Pre-warm: the Dart side boots while the user is still focusing a field.
        val e = group.createAndRunEngine(this, entrypoint)
        engine = e
        val messenger = e.dartExecutor.binaryMessenger
        ImeHostApi.setUp(messenger, ImeHostApiImpl(this))
        PlatformHostApi.setUp(messenger, PlatformHostApiImpl(applicationContext, EngineRole.IME))
        val api = ImeFlutterApi(messenger)
        flutterApi = api
        SettingsBus.attachIme(api)
    }

    override fun onCreateInputView(): View {
        val e = engine ?: error("Flutter engine missing")
        // Called again after configuration changes: move the engine to the new view.
        flutterView?.detachFromFlutterEngine()
        val view = FlutterView(this)
        view.attachToFlutterEngine(e)
        flutterView = view
        firstFrameShown = false
        view.addOnFirstFrameRenderedListener(object : FlutterUiDisplayListener {
            override fun onFlutterUiDisplayed() {
                firstFrameShown = true
                fallback?.visibility = View.GONE
            }

            override fun onFlutterUiNoLongerDisplayed() {}
        })

        val container = KeyboardContainer(this)
        container.addView(view, FrameLayout.LayoutParams(MATCH, MATCH))
        val fb = buildFallback()
        container.addView(fb, FrameLayout.LayoutParams(MATCH, MATCH))
        fallback = fb
        container.setOnApplyWindowInsetsListener { _, insets ->
            val bottom = if (Build.VERSION.SDK_INT >= 30) {
                insets.getInsets(WindowInsets.Type.navigationBars()).bottom
            } else {
                @Suppress("DEPRECATION")
                insets.systemWindowInsetBottom
            }
            // Reported in metrics only. Dart owns the total height (it adds the
            // bottom viewPadding Flutter actually applies), so the two sides can
            // never disagree about the inset.
            navBarInsetPx = bottom
            insets // not consumed: FlutterView still receives them as viewPadding
        }
        root = container
        applyHeight()
        return container
    }

    /** Never use the landscape full-screen "extract" editor. */
    override fun onEvaluateFullscreenMode(): Boolean = false

    override fun onStartInput(attribute: EditorInfo, restarting: Boolean) {
        super.onStartInput(attribute, restarting)
        flutterApi?.onStartInput(attribute.toMessage(), restarting) {}
    }

    override fun onStartInputView(info: EditorInfo, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        flutterApi?.onStartInputView(info.toMessage(), restarting) {}
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        flutterApi?.onFinishInputView(finishingInput) {}
    }

    override fun onFinishInput() {
        super.onFinishInput()
        flutterApi?.onFinishInput {}
    }

    override fun onUpdateSelection(
        oldSelStart: Int, oldSelEnd: Int, newSelStart: Int, newSelEnd: Int,
        candidatesStart: Int, candidatesEnd: Int,
    ) {
        super.onUpdateSelection(oldSelStart, oldSelEnd, newSelStart, newSelEnd, candidatesStart, candidatesEnd)
        flutterApi?.onUpdateSelection(
            SelectionMessage(
                oldSelStart.toLong(), oldSelEnd.toLong(), newSelStart.toLong(), newSelEnd.toLong(),
                candidatesStart.toLong(), candidatesEnd.toLong(),
            ),
        ) {}
    }

    override fun onWindowShown() {
        super.onWindowShown()
        engine?.lifecycleChannel?.appIsResumed()
        flutterApi?.onWindowShown {}
        if (!firstFrameShown) {
            main.removeCallbacks(fallbackCheck)
            main.postDelayed(fallbackCheck, FALLBACK_DELAY_MS)
        }
    }

    override fun onWindowHidden() {
        super.onWindowHidden()
        // Inactive (not paused): Flutter draws nothing while idle, and the next
        // show needs no frame-scheduling warm-up.
        engine?.lifecycleChannel?.appIsInactive()
        flutterApi?.onWindowHidden {}
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        flutterApi?.onConfigurationChanged(windowMetrics()) {}
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        flutterApi?.onTrimMemory(level.toLong()) {}
    }

    override fun onDestroy() {
        main.removeCallbacks(fallbackCheck)
        SettingsBus.attachIme(null)
        engine?.let { e ->
            val messenger = e.dartExecutor.binaryMessenger
            ImeHostApi.setUp(messenger, null)
            PlatformHostApi.setUp(messenger, null)
            flutterView?.detachFromFlutterEngine()
            e.destroy()
        }
        engine = null
        flutterView = null
        root = null
        super.onDestroy()
    }

    // ---- Called by ImeHostApiImpl ------------------------------------------------

    internal fun applyWindowLayout(layout: WindowLayoutMessage) {
        contentHeightDp = layout.heightDp.coerceIn(MIN_CONTENT_HEIGHT_DP, MAX_CONTENT_HEIGHT_DP)
        windowMode = layout.mode
        applyHeight()
    }

    internal fun feedbackView(): View? = root

    internal fun windowMetrics(): WindowMetricsMessage {
        val dm = resources.displayMetrics
        val config = resources.configuration
        return WindowMetricsMessage(
            screenWidthPx = dm.widthPixels.toLong(),
            screenHeightPx = dm.heightPixels.toLong(),
            density = dm.density.toDouble(),
            navigationBarInsetPx = navBarInsetPx.toLong(),
            isLandscape = config.orientation == Configuration.ORIENTATION_LANDSCAPE,
            smallestScreenWidthDp = config.smallestScreenWidthDp.toLong(),
            fontScale = config.fontScale.toDouble(),
            isNightMode = isNightMode(),
        )
    }

    private fun applyHeight() {
        val r = root ?: return
        val density = resources.displayMetrics.density
        r.fixedHeightPx = (contentHeightDp * density).roundToInt()
        r.requestLayout()
    }

    private fun buildFallback(): View {
        val tv = TextView(this)
        tv.text = "Myna is starting…  Tap here to switch keyboard"
        tv.gravity = Gravity.CENTER
        tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        val night = isNightMode()
        tv.setBackgroundColor(if (night) Color.rgb(28, 27, 31) else Color.rgb(243, 237, 247))
        tv.setTextColor(if (night) Color.rgb(230, 225, 229) else Color.rgb(28, 27, 31))
        tv.visibility = View.GONE
        tv.setOnClickListener {
            val switched = Build.VERSION.SDK_INT >= 28 && switchToPreviousInputMethod()
            if (!switched) {
                (getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager).showInputMethodPicker()
            }
        }
        return tv
    }

    /** FrameLayout whose height is dictated by Dart, not by its children. */
    private class KeyboardContainer(context: Context) : FrameLayout(context) {
        var fixedHeightPx = 0

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(fixedHeightPx, MeasureSpec.EXACTLY))
        }
    }

    private companion object {
        const val MATCH = FrameLayout.LayoutParams.MATCH_PARENT
        const val DEFAULT_CONTENT_HEIGHT_DP = 284.0
        const val MIN_CONTENT_HEIGHT_DP = 120.0
        const val MAX_CONTENT_HEIGHT_DP = 640.0
        const val FALLBACK_DELAY_MS = 2000L
    }
}
