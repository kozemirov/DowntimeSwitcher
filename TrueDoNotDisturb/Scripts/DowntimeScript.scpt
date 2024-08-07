tell application "System Events"
    set isRunning to (name of every process) contains "System Settings"
    if isRunning then
        tell application "System Settings" to quit
        delay 0.5
    end if
end tell

do shell script "open x-apple.systempreferences:com.apple.Screen-Time-Settings"

tell application "System Events"
    tell its application process "System Settings"
        set frontmost to true
        delay 1
        tell front window to key code 48
        tell front window to key code 48
        tell front window to key code 48
        tell front window to key code 48
        tell front window to key code 49
        tell front window to key code 49
    end tell
end tell

delay 0.5

tell application "System Events"
    set isRunning to (name of every process) contains "System Settings"
    if isRunning then
        tell application "System Settings" to quit
    end if
end tell
