//
//  DowntimeSwitcherApp.swift
//  DowntimeSwitcher
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI
import ApplicationServices
import ServiceManagement

@main
struct DowntimeSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var downtimeVM: DowntimeViewModel!
    private let menuBarIconEnabled = "MenuBarIconEnabled"
    private let menuBarIconDisabled = "MenuBarIconDisabled"
    var launchAtLoginEnabled: Bool = false
    private let spaces = "     "

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.downtimeVM = DowntimeViewModel()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem.button {
            if let image = NSImage(named: menuBarIconDisabled) {
                image.isTemplate = true
                statusButton.image = image
            }
            statusButton.target = self
            statusButton.action = #selector(handleStatusItemClick(_:))
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func handleStatusItemClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .leftMouseUp {
            leftClickScriptRun()
        } else if event.type == .rightMouseUp {
            rightClickMenuShow()
        }
    }

    func leftClickScriptRun() {
        Task {
            await self.downtimeVM.script()
            await changeStatusBarButton(state: self.downtimeVM.downtimeState)
        }
    }

    func rightClickMenuShow() {
        checkIfLaunchAtLogin()
        let menu = createMenu()
        if let button = statusItem.button {
            statusItem.menu = menu
            button.performClick(nil)
            statusItem.menu = nil
        }
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        let loginLaunch = NSMenuItem(title: "\(launchAtLoginEnabled ? "✓  " : spaces)Launch at login", action: #selector(toggleLoginLaunch), keyEquivalent: "")
        menu.addItem(loginLaunch)
        
        menu.addItem(NSMenuItem.separator())
        
        let accessibilityPermissions = NSMenuItem(title: "\(spaces)Request Necessary Accesibility Permission", action: #selector(requestAccessibilityPermission), keyEquivalent: "")
        menu.addItem(accessibilityPermissions)
        
        let automationPermissions = NSMenuItem(title: "\(spaces)Request Necessary Automation Permission", action: #selector(requestAutomationPermission), keyEquivalent: "")
        menu.addItem(automationPermissions)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "\(spaces)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        return menu
    }

    private func changeStatusBarButton(state: Bool) {
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                if let image = NSImage(named: state ? self.menuBarIconEnabled : self.menuBarIconDisabled) {
                    image.isTemplate = true
                    button.image = image
                }
            }
        }
    }

    @objc func toggleLoginLaunch() {
        launchAtLoginEnabled ? removeFromLoginItems() : addToLoginItems()
    }
    
    @objc func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            PermissionHelper.showAccessibilityAlert()
        }
    }
    
    @objc func requestAutomationPermission() {
        PermissionHelper.showAutomationAlert()
    }
    
    func addToLoginItems() {
        do {
            let appService = SMAppService.mainApp
            try appService.register()
            print("Successfully added to login items.")
        } catch {
            print("Failed to add to login items: \(error)")
        }
    }

    func removeFromLoginItems() {
        do {
            let appService = SMAppService.mainApp
            try appService.unregister()
            print("Successfully removed from login items.")
        } catch {
            print("Failed to remove from login items: \(error)")
        }
    }

    func checkIfLaunchAtLogin() {
        let appService = SMAppService.mainApp
        launchAtLoginEnabled = appService.status == .enabled
    }
}
