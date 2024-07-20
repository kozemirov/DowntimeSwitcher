//
//  TrueDoNotDisturbApp.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI
import ApplicationServices

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

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        self.downtimeVM = DowntimeViewModel()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "moon", accessibilityDescription: "Moon")
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
        let menu = createMenu()
        if let button = statusItem.button {
            statusItem.menu = menu
            button.performClick(nil)
            statusItem.menu = nil
        }
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        let loginLaunch = NSMenuItem(title: "Launch at login", action: #selector(addLoginLaunch), keyEquivalent: "")
        menu.addItem(loginLaunch)
        
        let permissions = NSMenuItem(title: "Request pesmissions", action: #selector(requestPermission), keyEquivalent: "")
        menu.addItem(permissions)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        return menu
    }

    private func changeStatusBarButton(state: Bool) {
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                button.image = NSImage(systemSymbolName: state ? "moon.fill" : "moon", accessibilityDescription: "Moon")
            }
        }
    }

    @objc func addLoginLaunch() {

    }
    
    @objc func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Accessibility permissions were not enabled by the user.")
        }
    }
}
