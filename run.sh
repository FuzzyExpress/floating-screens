cd "/home/evans/floating-screens/"

# godot --headless --export-debug "Android" WeylusVR.apk

# Use incremental install for faster updates (only changed parts)
adb shell am force-stop org.fexp.floatingscreens
adb install "Floating Screens.apk"
echo -ne \\a
notify-send "Starting Floating Screens"
adb shell am start -n org.fexp.floatingscreens/com.godot.game.GodotApp

trap "adb shell am force-stop org.fexp.floatingscreens" SIGINT

adb logcat | grep "godot   :"

trap "rm 'Floating Screens.apk'" EXIT
