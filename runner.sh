#!/bin/bash

#  I have since discovered that godot has a built in feature for this.

cd "/home/evans/floating-screens/" || exit 1

# Function to handle SIGINT cleanup
cleanup() {
    adb shell am force-stop org.fexp.floatingscreens
    exit
}
trap cleanup SIGINT

# Function to remove APK on exit
final_cleanup() {
    rm -f "Floating Screens.apk"
}
trap final_cleanup EXIT

# Watch for creation or modification of Floating Screens.apk
echo "Watching for Floating Screens.apk changes..."
inotifywait -m -e close_write,create --format '%w%f' . | while read -r file; do
    if [[ "$file" == *"Floating Screens.apk" ]]; then
        echo "Detected change in Floating Screens.apk"

        adb shell am force-stop org.fexp.floatingscreens
        adb install -r "Floating Screens.apk" >/dev/null
        echo -ne \\a
        notify-send "Starting Floating Screens"
        adb shell am start -n org.fexp.floatingscreens/com.godot.game.GodotApp

        echo "Monitoring logcat output..."
        adb logcat | grep --line-buffered "godot   :"
    fi
done
