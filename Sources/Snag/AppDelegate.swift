import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var eventMonitor: EventMonitor?

    private var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "enabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "enabled")
            updateIcon()
            if newValue {
                eventMonitor?.start()
            } else {
                eventMonitor?.stop()
            }
        }
    }

    private var launchAtLogin: Bool {
        get { UserDefaults.standard.bool(forKey: "launchAtLogin") }
        set {
            UserDefaults.standard.set(newValue, forKey: "launchAtLogin")
            if newValue {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        if !UserDefaults.standard.contains(key: "enabled") {
            UserDefaults.standard.set(true, forKey: "enabled")
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateIcon()

        statusItem.button?.action = #selector(toggleEnabled)
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        eventMonitor = EventMonitor()

        if isEnabled {
            eventMonitor?.start()
            pollForAccessibility()
        }

    }

    private func pollForAccessibility() {
        guard eventMonitor?.isRunning == false, isEnabled else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.eventMonitor?.start()
            self?.pollForAccessibility()
        }
    }

    @objc private func toggleEnabled() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            isEnabled.toggle()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        let enableItem = NSMenuItem(
            title: isEnabled ? "Disable" : "Enable",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enableItem.target = self
        menu.addItem(enableItem)

        menu.addItem(.separator())

        let loginItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        loginItem.target = self
        loginItem.state = launchAtLogin ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Snag",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggleLaunchAtLogin() {
        launchAtLogin.toggle()
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        if isEnabled {
            button.image = NSImage(
                systemSymbolName: "scissors",
                accessibilityDescription: "Snag enabled"
            )
        } else {
            button.image = NSImage(
                systemSymbolName: "scissors.badge.ellipsis",
                accessibilityDescription: "Snag disabled"
            )
        }
    }

}

extension UserDefaults {
    func contains(key: String) -> Bool {
        object(forKey: key) != nil
    }
}
