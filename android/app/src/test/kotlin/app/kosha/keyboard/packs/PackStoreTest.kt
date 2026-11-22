// SPDX-License-Identifier: GPL-3.0-or-later
package app.kosha.keyboard.packs

import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.io.File
import java.nio.file.Files
import java.security.KeyPair
import java.security.KeyPairGenerator
import java.security.MessageDigest
import java.security.Signature
import java.security.spec.ECGenParameterSpec
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Before
import org.junit.Test

class PackStoreTest {
    private lateinit var root: File
    private val keys = newKeys()
    private val other = newKeys()

    @Before
    fun setUp() {
        root = Files.createTempDirectory("packs").toFile()
    }

    @Test
    fun installsListsAndDeletes() {
        val store = PackStore(root, listOf(keys.public))
        val files = mapOf("model/a.onnx" to byteArrayOf(1, 2, 3), "tokens.txt" to "hi".toByteArray())
        val installed = store.install(ByteArrayInputStream(pack(files)))
        assertEquals("translate-en-es", installed.manifest.id)
        assertEquals(listOf("en", "es"), installed.manifest.languages)
        assertArrayEquals(byteArrayOf(1, 2, 3), File(store.dir("translate-en-es"), "model/a.onnx").readBytes())
        assertEquals(1, store.list().size)
        assertEquals("translate-en-es", store.find("translation", listOf("en", "es"))?.manifest?.id)
        store.delete("translate-en-es")
        assertTrue(store.list().isEmpty())
    }

    @Test
    fun replacesSameId() {
        val store = PackStore(root, listOf(keys.public))
        store.install(ByteArrayInputStream(pack(mapOf("a.bin" to byteArrayOf(1)))))
        store.install(ByteArrayInputStream(pack(mapOf("b.bin" to byteArrayOf(2)), version = 2)))
        val p = store.open("translate-en-es")!!
        assertEquals(2, p.manifest.version)
        assertTrue(!File(p.dir, "a.bin").exists())
        assertEquals(1, root.listFiles()!!.size)
    }

    @Test
    fun rejectsUntrustedSignature() = expect("bad_signature") {
        PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(pack(mapOf("a" to byteArrayOf(1)), signer = other)))
    }

    @Test
    fun rejectsTamperedFile() {
        val bytes = pack(mapOf("a.bin" to byteArrayOf(1, 2, 3)))
        bytes[bytes.size - 1] = 9
        expect("bad_signature") { PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(bytes)) }
        assertTrue(root.listFiles()!!.isEmpty())
    }

    @Test
    fun rejectsTruncatedAndTrailingData() {
        val bytes = pack(mapOf("a.bin" to byteArrayOf(1, 2, 3)))
        expect("bad_format") {
            PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(bytes.copyOf(bytes.size - 1)))
        }
        expect("bad_format") {
            PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(bytes + byteArrayOf(0)))
        }
    }

    @Test
    fun rejectsPathEscapes() {
        for (path in listOf("../x", "a/../../x", "/abs", "manifest.json", "a//b")) {
            expect("bad_format") {
                PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(pack(mapOf(path to byteArrayOf(1)))))
            }
        }
    }

    @Test
    fun rejectsWrongMagicVersionAndSize() {
        expect("bad_format") { PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(ByteArray(40))) }
        val v2 = pack(mapOf("a" to byteArrayOf(1)))
        v2[11] = 2
        expect("unsupported_version") { PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(v2)) }
        expect("too_large") {
            PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(pack(mapOf("a" to ByteArray(10)))), 5)
        }
    }

    @Test
    fun installsDictionaryPacks() {
        val store = PackStore(root, listOf(keys.public))
        val bytes = pack(mapOf("dict/base.bin" to byteArrayOf(7)), id = "dict-zh-rime", kind = "dictionary", languages = """["zh"]""")
        val installed = store.install(ByteArrayInputStream(bytes))
        assertEquals(PackManifest.KIND_DICTIONARY, installed.manifest.kind)
        assertArrayEquals(byteArrayOf(7), File(store.dir("dict-zh-rime"), "dict/base.bin").readBytes())
        assertEquals("dict-zh-rime", store.find("dictionary", listOf("zh"))?.manifest?.id)
    }

    @Test
    fun rejectsUnknownKind() = expect("bad_format") {
        PackStore(root, listOf(keys.public)).install(ByteArrayInputStream(pack(mapOf("a" to byteArrayOf(1)), kind = "code")))
    }

    @Test
    fun openRejectsEditedManifest() {
        val store = PackStore(root, listOf(keys.public))
        val p = store.install(ByteArrayInputStream(pack(mapOf("a" to byteArrayOf(1)))))
        File(p.dir, PackStore.MANIFEST).appendText(" ")
        assertNull(store.open("translate-en-es"))
    }

    // ---- helpers -------------------------------------------------------------------

    private fun expect(code: String, block: () -> Unit) {
        try {
            block()
            fail("expected $code")
        } catch (e: PackException) {
            assertEquals(code, e.code)
        }
    }

    private fun pack(
        files: Map<String, ByteArray>,
        version: Int = 1,
        signer: KeyPair = keys,
        id: String = "translate-en-es",
        kind: String = "translation",
        languages: String = """["en","es"]""",
    ): ByteArray {
        val list = files.entries.joinToString(",") { (path, data) ->
            """{"path":"$path","size":${data.size},"sha256":"${sha256(data)}"}"""
        }
        val manifest = ("""{"id":"$id","kind":"$kind","name":"English → Spanish",""" +
            """"version":$version,"languages":$languages,"engine":"test","license":"CC0-1.0","files":[$list]}""")
            .toByteArray()
        val sig = Signature.getInstance("SHA256withECDSA").run {
            initSign(signer.private)
            update(manifest)
            sign()
        }
        val out = ByteArrayOutputStream()
        DataOutputStream(out).apply {
            write(PackStore.MAGIC)
            writeInt(PackStore.FORMAT_VERSION)
            writeInt(manifest.size)
            write(manifest)
            writeInt(sig.size)
            write(sig)
            files.values.forEach { write(it) }
        }
        return out.toByteArray()
    }

    private fun sha256(b: ByteArray) = MessageDigest.getInstance("SHA-256").digest(b).toHex()

    private companion object {
        fun newKeys(): KeyPair =
            KeyPairGenerator.getInstance("EC").apply { initialize(ECGenParameterSpec("secp256r1")) }.generateKeyPair()
    }
}
