package com.wildduck.azkar.core

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class ConfigTest {
    @Test
    fun emptyConfigUsesDefaults() {
        val c = Config.decode("{}")
        assertEquals(Config(), c, "empty config uses defaults")
        assertEquals(3.0, c.intervalMinutes, "default interval")
        assertEquals(5, c.maxStack, "default max stack")
        assertEquals(Order.Random, c.order, "default order")
        assertEquals(Hotkey.parse("ctrl+alt+z"), c.hotkey, "default hotkey")
        assertEquals(TimeWindow(300, 660), c.sabah, "default sabah window")
        assertEquals(TimeWindow(930, 1260), c.masaa, "default masaa window")
        assertEquals(TimeWindow(1410, 300), c.quietHours, "default quiet hours")
        assertEquals(false, c.repeatGeneral, "general azkar are one tap by default")
    }

    @Test
    fun repeatGeneral() {
        assertEquals(true, Config.decode("""{"repeatGeneral": true}""").repeatGeneral, "repeatGeneral override")
        expectError("repeatGeneral must be a bool", mentioning = "repeatGeneral") {
            Config.decode("""{"repeatGeneral": 1}""")
        }
    }

    @Test
    fun generalPageSwitches() {
        val c = Config()
        assertEquals(true, c.openAtLogin, "starts at login by default")
        assertEquals(false, c.showWindowAtLogin, "starts quietly in the menu bar by default")
        assertEquals(true, c.showCount, "shows the card count next to 📿 by default")
        assertEquals(false, c.sound, "no sound by default")
        val o = Config.decode("""{"openAtLogin": false, "showWindowAtLogin": true, "showCount": false, "sound": true}""")
        assertEquals(false, o.openAtLogin, "openAtLogin override")
        assertEquals(true, o.showWindowAtLogin, "showWindowAtLogin override")
        assertEquals(false, o.showCount, "showCount override")
        assertEquals(true, o.sound, "sound override")
        for (key in listOf("openAtLogin", "showWindowAtLogin", "showCount", "sound")) {
            expectError("$key must be a bool", mentioning = key) { Config.decode("""{"$key": "yes"}""") }
        }
    }

    @Test
    fun partialConfig() {
        val c = Config.decode(
            """{"intervalMinutes": 0.5, "order": "sequential", "quietHours": null, "sabah": {"start": "04:30", "end": "10:00"}}""",
        )
        assertEquals(0.5, c.intervalMinutes, "interval override")
        assertEquals(Order.Sequential, c.order, "order override")
        assertNull(c.quietHours, "null disables quiet hours")
        assertEquals(TimeWindow(270, 600), c.sabah, "sabah override")
        assertEquals(Config().masaa, c.masaa, "unspecified keys keep defaults")
    }

    @Test
    fun invalidValues() {
        expectError("zero interval", mentioning = "intervalMinutes") { Config.decode("""{"intervalMinutes": 0}""") }
        expectError("zero max stack", mentioning = "maxStack") { Config.decode("""{"maxStack": 0}""") }
        expectError("bad hotkey", mentioning = "hotkey") { Config.decode("""{"hotkey": "ctrl+foo"}""") }
        expectError("bad order", mentioning = "order") { Config.decode("""{"order": "shuffle"}""") }
        expectError("bad clock", mentioning = "sabah") {
            Config.decode("""{"sabah": {"start": "25:00", "end": "11:00"}}""")
        }
        expectError("not json", mentioning = "JSON") { Config.decode("{nope") }
    }

    @Test
    fun booleansAndStringsAreNotNumbers() {
        expectError("a boolean is not an interval", mentioning = "intervalMinutes") {
            Config.decode("""{"intervalMinutes": true}""")
        }
        expectError("a boolean is not a max stack", mentioning = "maxStack") {
            Config.decode("""{"maxStack": true}""")
        }
        expectError("a boolean is not a font size", mentioning = "fontSize") {
            Config.decode("""{"fontSize": true}""")
        }
        expectError("a string is not a number", mentioning = "fontSize") { Config.decode("""{"fontSize": "22"}""") }
        assertEquals(3, Config.decode("""{"maxStack": 3.0}""").maxStack, "3.0 is a whole number")
        assertEquals(100, Config.decode("""{"maxStack": 1e2}""").maxStack, "1e2 is a whole number")
    }

    @Test
    fun encoding() {
        val c = Config(
            intervalMinutes = 0.5,
            hotkey = Hotkey.parse("cmd+shift+f5")!!,
            order = Order.Sequential,
            repeatGeneral = true,
            maxStack = 2,
            sabah = null,
            masaa = TimeWindow(1020, 1200),
            quietHours = null,
            fontSize = 26.5,
            sound = true,
            showCount = false,
            openAtLogin = false,
            showWindowAtLogin = true,
        )
        assertEquals(c, Config.decode(c.encode()), "encode round-trips through decode")
        val text = c.encode()
        assertTrue(""""sabah": null""" in text, "a switched-off window is written as null")
        assertTrue(""""masaa": { "start": "17:00", "end": "20:00" }""" in text, "windows are written as HH:mm")
        assertTrue(""""intervalMinutes": 0.5""" in text, "fractional numbers keep their fraction")
        assertEquals(Config(), Config.decode(Config().encode()), "defaults round-trip")
    }

    @Test
    fun exactBytes() {
        val defaults = """
            {
              "intervalMinutes": 3,
              "hotkey": "ctrl+alt+z",
              "order": "random",
              "repeatGeneral": false,
              "maxStack": 5,
              "sabah": { "start": "05:00", "end": "11:00" },
              "masaa": { "start": "15:30", "end": "21:00" },
              "quietHours": { "start": "23:30", "end": "05:00" },
              "fontSize": 22,
              "sound": false,
              "showCount": true,
              "openAtLogin": true,
              "showWindowAtLogin": false
            }
        """.trimIndent() + "\n"
        assertEquals(defaults, Config().encode(), "defaults are written in the settings window's layout")

        val numbers = listOf(
            3.0 to "3", 0.5 to "0.5", 26.5 to "26.5", 0.1 + 0.2 to "0.30000000000000004", 0.0001 to "0.0001",
            0.00001 to "1e-05", 1.5e-7 to "1.5e-07", 12345678.5 to "12345678.5", 99999999999999.5 to "99999999999999.5",
            1e15 to "1000000000000000.0", 9007199254740992.0 to "9007199254740992.0",
            9007199254740994.0 to "9.007199254740994e+15", 1.25e16 to "1.25e+16", 1e100 to "1e+100",
        )
        for ((n, text) in numbers) {
            assertTrue(
                "\n  \"fontSize\": $text,\n" in Config(fontSize = n).encode(),
                "fontSize $text is written as Swift writes it",
            )
        }
    }
}
