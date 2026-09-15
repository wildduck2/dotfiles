package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class LibraryTest {
    @Test
    fun decoding() {
        val l = Library.decode(
            """{"sabah": [{"text": "a", "source": "x"}, {"text": "b", "count": 3, "note": "n", "ref": 86}], "masaa": null}""",
        )
        assertEquals("a", l.sabah.first().text, "unknown keys are ignored")
        assertEquals(1, l.sabah.first().count, "count defaults to 1")
        assertNull(l.sabah.first().note, "note is optional")
        assertNull(l.sabah.first().ref, "ref is optional")
        assertEquals(Zikr("b", 3, "n", 86), l.sabah.last(), "a zikr with every field")
        assertEquals(emptyList(), l.masaa, "a null list is empty")
        assertEquals(emptyList(), l.general, "a missing list is empty")
    }

    @Test
    fun aZikrNeedsText() {
        expectError("a zikr needs text", mentioning = "text") { Library.decode("""{"general": [{"count": 3}]}""") }
    }
}
