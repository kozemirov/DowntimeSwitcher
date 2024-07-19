//
//  TrueDoNotDisturbApp.swift
//  TrueDoNotDisturb
//
//  Created by Pavel Kozemirov on 19/07/2024.
//

import SwiftUI

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
        self.downtimeVM = ScriptViewModel()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "1.circle", accessibilityDescription: "Line")
        }
        
        setupMenus()
    }
    
    func setupMenus() {
        // 1
        let menu = NSMenu()

        // 2
        let one = NSMenuItem(title: "One", action: #selector(didTapOne) , keyEquivalent: "1")
        menu.addItem(one)

        let two = NSMenuItem(title: "Two", action: #selector(didTapTwo) , keyEquivalent: "2")
        menu.addItem(two)

        let three = NSMenuItem(title: "Three", action: #selector(didTapThree) , keyEquivalent: "3")
        menu.addItem(three)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // 3
        statusItem.menu = menu
    }
    
    // 1
    private func changeStatusBarButton(number: Int) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "\(number).circle", accessibilityDescription: number.description)
        }
    }

    @objc func didTapOne() {
        changeStatusBarButton(number: 1)
    }

    @objc func didTapTwo() {
        changeStatusBarButton(number: 2)
    }

    @objc func didTapThree() {
        changeStatusBarButton(number: 3)
    }
}
