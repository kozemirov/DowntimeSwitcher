//
//  AccessibilityHelper.swift
//  DowntimeSwitcher
//
//  Created by Pavel Kozemirov on 20/07/2024.
//

import Foundation
import Cocoa

class AccessibilityHelper {
    static func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "To use all features of this application, please enable accessibility permissions in System Preferences."
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
