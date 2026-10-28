import AppKit
import SwiftUI

public final class LaunchpadWindow: NSPanel {
    override public var canBecomeKey: Bool { true }
    override public var canBecomeMain: Bool { true }

    override public func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        // Prevent AppKit from constraining the window below the menu bar or notch area.
        // This ensures the window covers the full physical display edge-to-edge.
        return frameRect
    }

    override public func scrollWheel(with event: NSEvent) {
        if LaunchpadWindowController.shared.handleScrollWheel(event: event) {
            return
        }
        super.scrollWheel(with: event)
    }
}

@MainActor
public final class LaunchpadWindowController: NSObject, NSWindowDelegate {
    public static let shared = LaunchpadWindowController()

    private var window: LaunchpadWindow?
    private var isVisible: Bool = false
    private var isDismissing: Bool = false
    private var lastDismissTime: TimeInterval = 0
    private var localEventMonitor: Any?
    private var lastScrollTime: TimeInterval = 0
    private var accumulatedScrollDelta: CGFloat = 0
    private var isScrollPagingLocked: Bool = false
    private var savedPresentationOptions: NSApplication.PresentationOptions = []

    private override init() {
        super.init()
    }

    public func toggle() {
        let now = Date().timeIntervalSinceReferenceDate
        if now - lastDismissTime < 0.35 {
            return
        }
        if isVisible && !isDismissing {
            dismiss()
        } else if !isVisible {
            present()
        }
    }

    public func present() {
        let now = Date().timeIntervalSinceReferenceDate
        if now - lastDismissTime < 0.35 {
            return
        }
        guard !isVisible, !isDismissing else { return }

        // Reset scroll accumulator
        accumulatedScrollDelta = 0
        lastScrollTime = 0

        // Find the screen currently containing the mouse cursor
        let mouseLocation = NSEvent.mouseLocation
        let targetScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main ?? NSScreen.screens[0]

        let screenFrame = targetScreen.frame

        // Ensure wallpaper for current screen is loaded
        WallpaperManager.shared.loadWallpaper(for: targetScreen)

        if window == nil {
            let panel = LaunchpadWindow(
                contentRect: screenFrame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .stationary]
            panel.hasShadow = false
            panel.isMovable = false
            panel.acceptsMouseMovedEvents = true
            panel.becomesKeyOnlyIfNeeded = false
            panel.delegate = self

            let hostingView = NSHostingView(
                rootView: LaunchpadOverlayView(scanner: .shared) { [weak self] in
                    self?.dismiss()
                }
                .ignoresSafeArea()
            )
            panel.contentView = hostingView
            self.window = panel
        }

        guard let win = window else { return }
        win.setFrame(screenFrame, display: true)
        
        // Hide Menu Bar and Dock so Launchpad is fully immersive and uninhibited across all Macs
        savedPresentationOptions = NSApp.presentationOptions
        NSApp.presentationOptions = [.hideMenuBar, .hideDock]

        // Setup local event monitor for Escape, Arrow keys, and Scroll Wheel
        setupEventMonitor()

        // Fade in animation
        win.alphaValue = 0.0
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            win.animator().alphaValue = 1.0
        }

        isVisible = true
    }

    public func restorePresentationOptions() {
        NSApp.presentationOptions = savedPresentationOptions
    }

    public func dismiss() {
        guard isVisible, !isDismissing, let win = window else { return }
        isDismissing = true
        lastDismissTime = Date().timeIntervalSinceReferenceDate

        removeEventMonitor()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            win.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                win.orderOut(nil)
                self.restorePresentationOptions()
                self.isVisible = false
                self.isDismissing = false
                AppScanner.shared.searchText = ""
            }
        })
    }

    public func handleScrollWheel(event: NSEvent) -> Bool {
        // If searching, let the vertical list scroll normally
        guard AppScanner.shared.searchText.isEmpty else { return false }

        let now = Date().timeIntervalSinceReferenceDate
        let isPrecise = event.hasPreciseScrollingDeltas

        if isPrecise {
            // Trackpad Gesture Phase Handling:
            // Unlock on new swipe began or when previous gesture completely ends
            if event.phase == .began {
                isScrollPagingLocked = false
                accumulatedScrollDelta = 0
            }

            if event.phase == .ended || event.phase == .cancelled {
                if event.momentumPhase == [] || event.momentumPhase == .ended {
                    isScrollPagingLocked = false
                    accumulatedScrollDelta = 0
                }
            }

            if event.momentumPhase == .ended {
                isScrollPagingLocked = false
                accumulatedScrollDelta = 0
            }

            // Once a page flip occurs in a gesture, lock until fingers lift
            guard !isScrollPagingLocked else { return true }

            // Enforce minimum cooldown between page turns
            guard now - lastScrollTime > 0.35 else { return true }

            let dx = event.scrollingDeltaX
            let dy = event.scrollingDeltaY

            // Only respond to horizontal swipes (ignore mostly vertical scrolls)
            guard abs(dx) >= abs(dy) * 0.75 && abs(dx) > 1.5 else { return false }

            accumulatedScrollDelta += dx
            let threshold: CGFloat = 45.0

            if accumulatedScrollDelta < -threshold {
                // Swipe left -> Next Page
                NotificationCenter.default.post(name: .launchpadNextPage, object: nil)
                isScrollPagingLocked = true
                accumulatedScrollDelta = 0
                lastScrollTime = now
                return true
            } else if accumulatedScrollDelta > threshold {
                // Swipe right -> Previous Page
                NotificationCenter.default.post(name: .launchpadPreviousPage, object: nil)
                isScrollPagingLocked = true
                accumulatedScrollDelta = 0
                lastScrollTime = now
                return true
            }
        } else {
            // Clicky / notched mouse wheel
            guard now - lastScrollTime > 0.35 else { return true }
            let dy = event.scrollingDeltaY != 0 ? event.scrollingDeltaY : event.deltaY
            let dx = event.scrollingDeltaX != 0 ? event.scrollingDeltaX : event.deltaX
            let delta = abs(dx) > abs(dy) ? dx : dy

            if delta < -0.2 {
                // Wheel down -> Next Page
                NotificationCenter.default.post(name: .launchpadNextPage, object: nil)
                lastScrollTime = now
                return true
            } else if delta > 0.2 {
                // Wheel up -> Previous Page
                NotificationCenter.default.post(name: .launchpadPreviousPage, object: nil)
                lastScrollTime = now
                return true
            }
        }

        return false
    }

    private func setupEventMonitor() {
        removeEventMonitor()
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .scrollWheel]) { [weak self] event in
            if event.type == .keyDown {
                // KeyCode 53 is Escape
                if event.keyCode == 53 {
                    if AppScanner.shared.activeFolder != nil {
                        AppScanner.shared.activeFolder = nil
                        return nil
                    }
                    self?.dismiss()
                    return nil
                }

                // If user presses configured hotkey (e.g. Option+Space) while Launchpad is open, toggle closed
                if HotKeyManager.shared.matchesCurrentShortcut(event: event) {
                    self?.dismiss()
                    return nil
                }

                // KeyCode 49 is Spacebar -> Quick Look Preview
                if event.keyCode == 49 && AppScanner.shared.searchText.isEmpty {
                    NotificationCenter.default.post(name: .launchpadToggleQuickLook, object: nil)
                    return nil
                }
                // Arrow keys for paging when search text is empty
                if AppScanner.shared.searchText.isEmpty {
                    if event.keyCode == 123 { // Left Arrow
                        NotificationCenter.default.post(name: .launchpadPreviousPage, object: nil)
                        return nil
                    } else if event.keyCode == 124 { // Right Arrow
                        NotificationCenter.default.post(name: .launchpadNextPage, object: nil)
                        return nil
                    }
                }
            } else if event.type == .scrollWheel {
                if let handled = self?.handleScrollWheel(event: event), handled {
                    return nil
                }
            }
            return event
        }
    }

    private func removeEventMonitor() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }

    public func windowDidResignKey(_ notification: Notification) {
        // Automatically dismiss if clicked outside or lost focus
        if isVisible && !isDismissing {
            dismiss()
        }
    }
}

extension Notification.Name {
    public static let launchpadPreviousPage = Notification.Name("launchpadPreviousPage")
    public static let launchpadNextPage = Notification.Name("launchpadNextPage")
    public static let launchpadToggleQuickLook = Notification.Name("launchpadToggleQuickLook")
}
