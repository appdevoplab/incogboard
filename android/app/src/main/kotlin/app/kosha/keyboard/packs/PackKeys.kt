// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.packs

import java.security.PublicKey

/**
 * Public keys that may sign model packs. OWNER: orchestrator.
 *
 * DEV key (2026-11-21): the private half lives outside the repository on the developer machine
 * (`%USERPROFILE%\.kosha\keys\pack-dev.pem`). Wave 5 replaces it with the release key.
 */
object PackKeys {
    private const val DEV_2026 =
        "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE2yIInOWy82d4ORUtXVclEvy1PIiC2RL4lF8pvLIz1XRaCf+pBsWYUcW/3JnSTYGiUklDlhchYrOhCdfxyo1tZg=="

    fun trusted(): List<PublicKey> = listOf(PackStore.publicKey(DEV_2026))
}
