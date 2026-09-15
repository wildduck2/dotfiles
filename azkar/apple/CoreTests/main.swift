// Tests for apple/Core. Run with: apple/build.sh test
import Foundation

clockTests()
hotkeyTests()
configTests()
pickerTests()
tickTests()
tapCounterTests()
startupTests()
shippedFilesTests()

print("\(passed) passed, \(failed) failed")
exit(failed == 0 ? 0 : 1)
