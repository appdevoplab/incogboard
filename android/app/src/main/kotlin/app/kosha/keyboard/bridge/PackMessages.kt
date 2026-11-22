// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.bridge

import app.kosha.keyboard.packs.InstalledPack
import app.kosha.keyboard.packs.PackManifest

internal fun InstalledPack.toMessage() = PackInfoMessage(
    id = manifest.id,
    kind = when (manifest.kind) {
        PackManifest.KIND_VOICE -> PackKind.VOICE
        PackManifest.KIND_DICTIONARY -> PackKind.DICTIONARY
        else -> PackKind.TRANSLATION
    },
    name = manifest.name,
    version = manifest.version.toLong(),
    languages = manifest.languages,
    sizeBytes = sizeBytes,
    engine = manifest.engine,
    license = manifest.license,
)
