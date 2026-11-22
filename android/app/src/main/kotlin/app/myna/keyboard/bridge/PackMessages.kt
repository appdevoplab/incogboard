// SPDX-License-Identifier: GPL-3.0-or-later
package app.myna.keyboard.bridge

import app.myna.keyboard.packs.InstalledPack
import app.myna.keyboard.packs.PackManifest

internal fun InstalledPack.toMessage() = PackInfoMessage(
    id = manifest.id,
    kind = if (manifest.kind == PackManifest.KIND_VOICE) PackKind.VOICE else PackKind.TRANSLATION,
    name = manifest.name,
    version = manifest.version.toLong(),
    languages = manifest.languages,
    sizeBytes = sizeBytes,
    engine = manifest.engine,
    license = manifest.license,
)
