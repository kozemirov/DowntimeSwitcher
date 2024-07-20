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
    private var downtimeVM: ScriptViewModel!

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        requestAccessibilityPermission()
        self.downtimeVM = ScriptViewModel()

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
        if event.type == .rightMouseUp {
            showMenu()
        } else if event.type == .leftMouseUp {
            performLeftClickAction()
        }
    }

    func performLeftClickAction() {
        changeStatusBarButton(number: 2)
        Task {
            await self.downtimeVM.script()
        }
    }

    func showMenu() {
        let menu = createMenu()
        if let button = statusItem.button {
            statusItem.menu = menu
            button.performClick(nil)
            statusItem.menu = nil
        }
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()

        let one = NSMenuItem(title: "One", action: #selector(didTapOne), keyEquivalent: "1")
        menu.addItem(one)

        let two = NSMenuItem(title: "Two", action: #selector(didTapTwo), keyEquivalent: "2")
        menu.addItem(two)
        
        let three = NSMenuItem(title: "Access", action: #selector(didTapThree), keyEquivalent: "3")
        menu.addItem(three)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        return menu
    }

    private func changeStatusBarButton(number: Int) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: number == 1 ? "moon" : "moon.fill", accessibilityDescription: "Moon")
        }
    }

    @objc func didTapOne() {
        changeStatusBarButton(number: 1)
    }

    @objc func didTapTwo() {
        changeStatusBarButton(number: 2)
    }
    
    @objc func didTapThree() {
        requestAccessibilityPermission()
    }
    
    func requestAccessibilityPermission() {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            let accessEnabled = AXIsProcessTrustedWithOptions(options)
            
            if !accessEnabled {
                print("Accessibility permissions were not enabled by the user.")
            }
        }
}
