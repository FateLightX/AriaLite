import AppKit
import SwiftUI

@MainActor
enum AppPresentation {
    private static var mainWindowPresentationRequested = false
    private static var ignoreMainWindowDisappearUntil: Date?

    static func showMainWindow(using openWindow: OpenWindowAction, store: AppStore) {
        mainWindowPresentationRequested = true
        prepareForWindowPresentation(store: store)
        openWindow(id: "main")
        activateOnNextRunLoop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            mainWindowPresentationRequested = false
        }
    }

    static func showSettings(using openSettings: OpenSettingsAction, store: AppStore) {
        prepareForWindowPresentation(store: store)
        openSettings()
        activateOnNextRunLoop()
    }

    static func mainWindowDidAppear(store: AppStore) {
        let mainWindow = NSApp.windows.first { $0.title == "AriaLite" }
            ?? NSApp.windows.first(where: \.canBecomeMain)
        mainWindow?.isRestorable = false

        if !store.settings.showMainWindowOnLaunch && !mainWindowPresentationRequested {
            ignoreMainWindowDisappearUntil = Date().addingTimeInterval(1)
            mainWindow?.orderOut(nil)
            updateActivationPolicy(store: store)
            return
        }

        mainWindowPresentationRequested = false
        prepareForWindowPresentation(store: store)
    }

    static func mainWindowDidDisappear(store: AppStore) {
        DispatchQueue.main.async {
            if let deadline = ignoreMainWindowDisappearUntil, Date() < deadline {
                ignoreMainWindowDisappearUntil = nil
                updateActivationPolicy(store: store)
                return
            }

            if store.settings.keepRunningAfterMainWindowClose {
                updateActivationPolicy(store: store)
            } else {
                NSApp.terminate(nil)
            }
        }
    }

    static func settingsDidAppear(store: AppStore) {
        prepareForWindowPresentation(store: store)
        activateOnNextRunLoop()
    }

    static func settingsDidDisappear(store: AppStore) {
        DispatchQueue.main.async {
            updateActivationPolicy(store: store)
        }
    }

    static func updateActivationPolicy(store: AppStore) {
        // Keep dock hidden while windows are open when the setting is enabled.
        let shouldHideDock = store.settings.hideDockIconInMenuBarMode
        let targetPolicy: NSApplication.ActivationPolicy = shouldHideDock ? .accessory : .regular
        if NSApp.activationPolicy() != targetPolicy {
            NSApp.setActivationPolicy(targetPolicy)
        }
    }

    private static func prepareForWindowPresentation(store: AppStore) {
        updateActivationPolicy(store: store)
    }

    private static func activateOnNextRunLoop() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
