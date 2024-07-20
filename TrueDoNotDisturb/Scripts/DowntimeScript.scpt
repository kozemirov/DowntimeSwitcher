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
    if exists application process "System Settings" then
        keystroke "q" using command down
    end if
end tell
