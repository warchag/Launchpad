import SwiftUI
import Carbon

public struct SettingsView: View {
    @ObservedObject var settings: AppSettings = .shared
    @ObservedObject var scanner: AppScanner = .shared
    @State private var selectedTab: Int = 0
    @State private var isRecordingShortcut: Bool = false
    @State private var shortcutMonitor: Any?

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Header Tabs
            Picker("", selection: $selectedTab) {
                Label("Layout & Icons", systemImage: "square.grid.3x3.fill").tag(0)
                Label("Appearance", systemImage: "sparkles").tag(1)
                Label("General & Features", systemImage: "gearshape.fill").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if selectedTab == 0 {
                        layoutSection
                    } else if selectedTab == 1 {
                        appearanceSection
                    } else {
                        generalSection
                    }
                }
                .padding(24)
            }

            Divider()

            // Footer
            HStack {
                Button("Reset to Defaults") {
                    settings.resetToDefaults()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

                Spacer()

                Button("Done") {
                    stopRecording()
                    SettingsWindowController.shared.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 560, height: 560)
        .onDisappear {
            stopRecording()
        }
    }

    // 1. Layout & Icons Tab
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            // Icon Size Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("App Icon Size")
                        .font(.headline)
                    Spacer()
                    Text(settings.iconSize == 64 ? "64 px (Classic iOS / Launchpad)" : "\(Int(settings.iconSize)) px")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.accentColor)
                }

                HStack(spacing: 12) {
                    Image(systemName: "app")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Slider(value: $settings.iconSize, in: 48...96, step: 2)

                    Image(systemName: "app")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Adjust icon size (Classic Apple standard is 64px).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if settings.iconSize != 64 {
                        Button("Reset to 64px") {
                            settings.iconSize = 64
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                }
            }

            Divider()

            // Grid Layout Preset
            VStack(alignment: .leading, spacing: 8) {
                Text("Grid Layout (Columns × Rows)")
                    .font(.headline)

                Picker("", selection: Binding(
                    get: { "\(settings.gridColumns)x\(settings.gridRows)" },
                    set: { val in
                        let parts = val.components(separatedBy: "x")
                        if parts.count == 2, let c = Int(parts[0]), let r = Int(parts[1]) {
                            settings.gridColumns = c
                            settings.gridRows = r
                        }
                    }
                )) {
                    Text("6 × 4 (24 Apps per page - Spacious)").tag("6x4")
                    Text("7 × 5 (35 Apps per page - Classic macOS)").tag("7x5")
                    Text("8 × 5 (40 Apps per page - Compact)").tag("8x5")
                    Text("8 × 6 (48 Apps per page - Dense)").tag("8x6")
                }
                .pickerStyle(.radioGroup)

                Text("Determines how many applications fit on each Launchpad page.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Icon Organization & Sorting
            VStack(alignment: .leading, spacing: 10) {
                Text("Icon Sorting & Organization")
                    .font(.headline)

                Toggle(isOn: $settings.autoSortAlphabetically) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-sort All Apps Alphabetically (A-Z)")
                            .font(.system(size: 13, weight: .medium))
                        Text(settings.autoSortAlphabetically
                             ? "Apps and folders automatically stay sorted A-Z. When removed from a folder, an app returns to its alphabetical slot."
                             : "Classic mode: When removed from a folder, an app is placed right next to that folder on the current page.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    Button("Sort All Icons A-Z Now") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            AppScanner.shared.sortAlphabetically()
                        }
                    }
                    .font(.system(size: 12))

                    Button("Sync Groups from macOS") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            AppScanner.shared.importSystemGroups()
                        }
                    }
                    .font(.system(size: 12))

                    Spacer()
                }
                .padding(.top, 4)

                Text("Sync Groups imports the native 'Other' / Utilities and system folders directly from macOS.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // 2. Appearance Tab
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            // Wallpaper Blur Intensity
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Wallpaper Blur Intensity")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(settings.blurRadius)) px")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.accentColor)
                }

                Slider(value: $settings.blurRadius, in: 15...85, step: 5)

                Text("Controls how strongly your current desktop wallpaper is blurred.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Background Dimming
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Background Darkening (Dimming)")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(settings.backgroundOpacity * 100))%")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.accentColor)
                }

                Slider(value: $settings.backgroundOpacity, in: 0.15...0.70, step: 0.05)

                Text("Controls the darkness layer over your blurred wallpaper.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Blur Style
            VStack(alignment: .leading, spacing: 8) {
                Text("Frosted Glass Blur Style")
                    .font(.headline)

                Picker("", selection: $settings.blurMaterialIndex) {
                    Text("FullScreen UI (Apple Standard Vibrant)").tag(0)
                    Text("HUD Window (Deep Contrast Blur)").tag(1)
                    Text("Translucent Glass (Lighter Accent)").tag(2)
                }
                .pickerStyle(.radioGroup)
            }
        }
    }

    // 3. General & Features Tab
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Dock Usage Information Card
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "dock.rectangle")
                    .font(.system(size: 22))
                    .foregroundColor(.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("การใช้งานผ่าน Dock (แนะนำ)")
                        .font(.system(size: 13, weight: .semibold))
                    Text("คลิกไอคอน Launchpad ใน Dock เพื่อเปิดหรือสลับปิดหน้าต่างได้ทันที ปิดหน้าต่างได้ง่ายๆ ด้วยการคลิกพื้นที่ว่างหรือกดปุ่ม Esc")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .background(Color.accentColor.opacity(0.06))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
            )

            // Hot Corner Trigger
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hot Corner (สะบัดเมาส์ชนมุมจอ)")
                            .font(.headline)
                        Text("เลื่อนเคอร์เซอร์ไปแตะมุมหน้าจอที่เลือกเพื่อเรียก Launchpad ขึ้นมาทันที")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Picker("", selection: $settings.hotCorner) {
                        Text("ปิด (None)").tag("none")
                        Text("มุมซ้ายบน (Top-Left)").tag("top_left")
                        Text("มุมขวาบน (Top-Right)").tag("top_right")
                        Text("มุมซ้ายล่าง (Bottom-Left)").tag("bottom_left")
                        Text("มุมขวาล่าง (Bottom-Right)").tag("bottom_right")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 170)
                }
            }

            Divider()

            // Haptic Feedback
            Toggle(isOn: $settings.enableHapticFeedback) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("การสั่นตอบสนอง (Haptic Feedback)")
                        .font(.headline)
                    Text("สั่นเบาๆ บนแทร็คแพดเมื่อคลิกเปิดแอป เปลี่ยนหน้า หรือลากรวมโฟลเดอร์")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Recent Apps Shelf
            Toggle(isOn: $settings.showRecentApps) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("แสดงแถบแอปล่าสุด (Recent Apps Shelf)")
                        .font(.headline)
                    Text("แสดงแถว 6 แอพที่เปิดล่าสุดไว้ด้านบนสุดของหน้าแรก")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Startup & Dock toggles
            Toggle(isOn: $settings.launchAtLogin) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at Login")
                        .font(.headline)
                    Text("Automatically start Launchpad helper when you start your Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Toggle(isOn: $settings.showDockIcon) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Keep Launchpad in Dock")
                        .font(.headline)
                    Text("แสดงไอคอน Launchpad ไว้ใน Dock เพื่อให้คลิกเปิด/ปิดได้ตลอดเวลา")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Toggle(isOn: $settings.autoFocusSearch) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-focus Search Field")
                        .font(.headline)
                    Text("Focuses the search bar immediately when Launchpad opens.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Global Keyboard Shortcut (Optional)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Global Keyboard Shortcut (ตัวเลือกเสริม)")
                            .font(.headline)
                        Text("เลือกปุ่มลัดเสริม หรือปิดไว้เพื่อใช้การคลิกผ่าน Dock เป็นหลัก")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(settings.shortcutDisplayString)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.15))
                        .foregroundColor(.accentColor)
                        .cornerRadius(6)
                }

                Picker("", selection: $settings.shortcutPreset) {
                    Text("ปิดปุ่มลัด (คลิกผ่าน Dock อย่างเดียว)").tag("none")
                    Text("⌥ Space (Option + Space)").tag("option_space")
                    Text("⌃ Space (Control + Space)").tag("control_space")
                    Text("⇧⌘L (Shift + Command + L)").tag("command_shift_l")
                    Text("Custom Shortcut (บันทึกปุ่มเอง)...").tag("custom")
                }
                .pickerStyle(.menu)

                if settings.shortcutPreset == "custom" {
                    customShortcutRecorderView
                }
            }

            Divider()

            // Hidden Apps Manager Card
            hiddenAppsCard

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Library Cache")
                        .font(.headline)
                    Text("Rescan /Applications and refresh newly installed apps.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Refresh Now") {
                    AppScanner.shared.refreshApps()
                }
            }
        }
    }

    // Hidden Apps Section
    private var hiddenAppsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.slash.fill")
                            .foregroundColor(.secondary)
                        Text("แอปที่ถูกซ่อนไว้ (\(settings.hiddenAppPaths.count))")
                            .font(.headline)
                    }
                    Text("คลิกขวาที่แอปใน Launchpad แล้วเลือก 'Hide from Launchpad' เพื่อซ่อน")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if !settings.hiddenAppPaths.isEmpty {
                    Button("กู้คืนทั้งหมด (Unhide All)") {
                        withAnimation {
                            settings.unhideAllApps()
                        }
                        HapticManager.shared.playAction()
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }

            if settings.hiddenAppPaths.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("ไม่มีแอปที่ถูกซ่อนอยู่ แสดงแอปครบทุกตัว")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } else {
                VStack(spacing: 6) {
                    ForEach(settings.hiddenAppPaths, id: \.self) { path in
                        let filename = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
                        let icon = NSWorkspace.shared.icon(forFile: path)
                        HStack(spacing: 8) {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                            Text(filename)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            Spacer()
                            Button("กู้คืน") {
                                withAnimation {
                                    settings.unhideApp(path: path)
                                }
                                HapticManager.shared.playClick()
                            }
                            .font(.system(size: 11))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Color.secondary.opacity(0.08)))
                    }
                }
                .frame(maxHeight: 160)
            }
        }
    }

    // Custom Shortcut Recorder View
    private var customShortcutRecorderView: some View {
        HStack(spacing: 12) {
            Button(action: {
                if isRecordingShortcut {
                    stopRecording()
                } else {
                    startRecording()
                }
            }) {
                HStack(spacing: 8) {
                    if isRecordingShortcut {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text("กดปุ่มบนคีย์บอร์ดที่ต้องการ... (กด Esc เพื่อยกเลิก)")
                            .font(.system(size: 12, weight: .medium))
                    } else {
                        Image(systemName: "record.circle")
                        Text(settings.shortcutDisplayString.isEmpty ? "คลิกเพื่อบันทึกปุ่มลัดใหม่" : "บันทึกปุ่มลัดใหม่: \(settings.shortcutDisplayString)")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isRecordingShortcut ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isRecordingShortcut ? Color.accentColor : Color.secondary.opacity(0.2), lineWidth: isRecordingShortcut ? 1.5 : 1)
                )
            }
            .buttonStyle(.plain)

            if isRecordingShortcut {
                Button("Cancel") {
                    stopRecording()
                }
                .font(.system(size: 12))
            }
        }
        .padding(.vertical, 4)
    }

    private func startRecording() {
        stopRecording()
        isRecordingShortcut = true

        shortcutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                stopRecording()
                return nil
            }

            var carbonMods: UInt32 = 0
            if event.modifierFlags.contains(.control) { carbonMods |= UInt32(controlKey) }
            if event.modifierFlags.contains(.option) { carbonMods |= UInt32(optionKey) }
            if event.modifierFlags.contains(.shift) { carbonMods |= UInt32(shiftKey) }
            if event.modifierFlags.contains(.command) { carbonMods |= UInt32(cmdKey) }

            settings.customKeyCode = Int(event.keyCode)
            settings.customModifiers = Int(carbonMods)
            settings.shortcutPreset = "custom"

            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecordingShortcut = false
        if let monitor = shortcutMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutMonitor = nil
        }
    }
}
