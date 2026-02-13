import AppKit
import CoreGraphics

final class EventMonitor {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isDragging = false
    private var lastClickCount: Int64 = 0
    var isRunning: Bool { eventTap != nil }

    static func requestAccessibilityPermission() -> Bool {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        )
    }

    func start() {
        guard eventTap == nil else { return }

        if !Self.requestAccessibilityPermission() {
            NSLog("[Snag] Accessibility permission not granted")
            return
        }

        let eventMask: CGEventMask =
            (1 << CGEventType.leftMouseDown.rawValue) |
            (1 << CGEventType.leftMouseDragged.rawValue) |
            (1 << CGEventType.leftMouseUp.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            NSLog("[Snag] Failed to create event tap")
            return
        }

        NSLog("[Snag] Event tap created successfully")
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
        isDragging = false
        lastClickCount = 0
    }

    fileprivate func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .leftMouseDown:
            lastClickCount = event.getIntegerValueField(.mouseEventClickState)

        case .leftMouseDragged:
            isDragging = true

        case .leftMouseUp:
            let clickState = event.getIntegerValueField(.mouseEventClickState)
            let isMultiClick = clickState >= 2 || lastClickCount >= 2
            if isDragging || isMultiClick {
                isDragging = false
                lastClickCount = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.simulateCopy()
                }
            }

        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap = eventTap {
                CGEvent.tapEnable(tap: tap, enable: true)
            }

        default:
            break
        }

        return Unmanaged.passRetained(event)
    }

    private func simulateCopy() {
        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        else { return }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}

private func eventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else { return Unmanaged.passRetained(event) }
    let monitor = Unmanaged<EventMonitor>.fromOpaque(userInfo).takeUnretainedValue()
    return monitor.handleEvent(type: type, event: event)
}
