package com.wildduck.azkar.desktop

import kotlin.io.path.createTempDirectory
import kotlin.io.path.deleteRecursively
import kotlin.test.AfterTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class SingleInstanceTest {
    private val dir = createTempDirectory("azkar-instance")

    @AfterTest
    fun cleanUp() {
        @OptIn(kotlin.io.path.ExperimentalPathApi::class)
        dir.deleteRecursively()
    }

    @Test
    fun aSecondLaunchOpensTheWindowOfTheFirst() {
        val first = assertNotNull(SingleInstance.claim(dir), "the first launch keeps the lock")
        var asked = 0
        first.onOpenRequest { asked += 1 }

        assertNull(SingleInstance.claim(dir), "a second launch does not run twice")
        assertTrue(waitFor { asked == 1 }, "it asks the running app to open its window instead")

        first.close()
        val next = assertNotNull(SingleInstance.claim(dir), "once it quits, the next launch takes over")
        next.close()
    }

    private fun waitFor(until: () -> Boolean): Boolean {
        val deadline = System.currentTimeMillis() + 5_000
        while (System.currentTimeMillis() < deadline) {
            if (until()) return true
            Thread.sleep(20)
        }
        return false
    }
}
