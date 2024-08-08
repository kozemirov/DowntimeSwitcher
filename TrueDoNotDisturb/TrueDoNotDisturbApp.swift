//
//  TrueDoNotDisturbApp.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI
import ApplicationServices
import ServiceManagement

@main
struct TrueDoNotDisturbApp: App {
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

        let loginLaunch = NSMenuItem(title: "\(launchAtLoginEnabled ? "✓  " : "     ")Launch at login", action: #selector(toggleLoginLaunch), keyEquivalent: "")
        menu.addItem(loginLaunch)
        
        let permissions = NSMenuItem(title: "     Request required permissions", action: #selector(requestPermission), keyEquivalent: "")
        menu.addItem(permissions)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "     Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

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
    
    @objc func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
//            AccessibilityHelper.showAccessibilityAlert()
            print("Accessibility permissions were not enabled by the user.")
        }
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
