// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.voice

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle

/**
 * Microphone permission. An IME cannot show a permission dialog itself, so [request] starts the
 * transparent, non-exported [MicPermissionActivity]. OWNER: Wave 3-D (stub from the orchestrator).
 */
object MicPermission {
    fun granted(context: Context): Boolean =
        context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED

    /** Wave 3-D: launch [MicPermissionActivity] and resume with the user's answer. */
    suspend fun request(context: Context): Boolean = granted(context)
}

/** Transparent activity that only asks for RECORD_AUDIO and finishes. Wave 3-D implements it. */
class MicPermissionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        finish()
    }
}
