import SwiftUI
import Carbon

public struct SettingsView: View {
    @ObservedObject var settings: AppSettings = .shared
    @ObservedObject var scanner: AppScanner = .shared
    @State private var isRecordingShortcut: Bool = false
    @State private var shortcutMonitor: Any?
    @State private var isCopiedDonate: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    generalSection

                    Divider()

                    appearanceSection

                    Divider()

                    layoutSection

                    Divider()

                    contactSection
                }
                .padding(24)
            }

            Divider()

            // Footer
            HStack {
                Button("คืนค่าเริ่มต้น") {
                    settings.resetToDefaults()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(.secondary)

                Spacer()

                Button("เสร็จสิ้น") {
                    stopRecording()
                    SettingsWindowController.shared.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 560, height: 600)
        .onDisappear {
            stopRecording()
        }
    }

    // 1. Layout & Icons Tab
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            // Icon Organization & Sorting
            VStack(alignment: .leading, spacing: 10) {
                Text("การจัดเรียงไอคอนและแอป")
                    .font(.headline)

                Toggle(isOn: $settings.autoSortAlphabetically) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("จัดเรียงแอปทั้งหมดตามตัวอักษร (ก-ฮ / A-Z) อัตโนมัติ")
                            .font(.system(size: 13, weight: .medium))
                        Text(settings.autoSortAlphabetically
                             ? "แอปและโฟลเดอร์จะจัดเรียงตามลำดับ ก-ฮ / A-Z เสมอ เมื่อนำแอปออกจากโฟลเดอร์จะกลับเข้าตำแหน่งตามตัวอักษรทันที"
                             : "โหมดคลาสสิก: เมื่อดึงแอปออกจากโฟลเดอร์ แอปจะวางอยู่ข้างๆ โฟลเดอร์นั้นในหน้าปัจจุบัน")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    Button("จัดเรียง ก-ฮ ทันที") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            AppScanner.shared.sortAlphabetically()
                        }
                    }
                    .font(.system(size: 12))

                    Button("ซิงค์โฟลเดอร์จาก macOS") {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            AppScanner.shared.importSystemGroups()
                        }
                    }
                    .font(.system(size: 12))

                    Spacer()
                }
                .padding(.top, 4)

                Text("ซิงค์โฟลเดอร์เริ่มต้นจาก macOS เช่น โฟลเดอร์ 'Other' และโฟลเดอร์ยูทิลิตี้ของระบบ")
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
                    Text("ระดับความเบลอของภาพพื้นหลัง (Wallpaper Blur)")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(settings.blurRadius)) px")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.accentColor)
                }

                Slider(value: $settings.blurRadius, in: 15...85, step: 5)

                Text("ปรับระดับความเบลอของภาพวอลเปเปอร์หน้าจอปัจจุบัน")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Background Dimming
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("ความมืดของพื้นหลัง (Background Dimming)")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(settings.backgroundOpacity * 100))%")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.accentColor)
                }

                Slider(value: $settings.backgroundOpacity, in: 0.15...0.70, step: 0.05)

                Text("ปรับเลเยอร์ความมืดเพื่อให้มองเห็นไอคอนแอปได้อย่างคมชัด")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                    Text("เปิดใช้งานอัตโนมัติเมื่อเริ่มระบบ (Launch at Login)")
                        .font(.headline)
                    Text("เปิดระบบ Launchpad ช่วยเหลืออัตโนมัติทุกครั้งเมื่อเปิดเครื่อง Mac")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Toggle(isOn: $settings.showDockIcon) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("แสดงไอคอน Launchpad ไว้ใน Dock")
                        .font(.headline)
                    Text("ตรึงไอคอน Launchpad ไว้ใน Dock เพื่อให้คลิกเปิด/ปิดได้ตลอดเวลา")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Toggle(isOn: $settings.autoFocusSearch) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("โฟกัสช่องค้นหาทันที (Auto-focus Search)")
                        .font(.headline)
                    Text("สามารถพิมพ์ค้นหาชื่อแอปได้ทันทีเมื่อเปิดหน้า Launchpad")
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
                    Text("แคชรายการแอปพลิเคชัน")
                        .font(.headline)
                    Text("สแกนโฟลเดอร์ /Applications ใหม่เพื่ออัปเดตแอปที่เพิ่งติดตั้ง")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("สแกนและรีเฟรชตอนนี้") {
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
                Button("ยกเลิก") {
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

    // Contact & Support Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.pink)
                Text("ติดต่อ & สนับสนุนผู้พัฒนา")
                    .font(.headline)
            }

            VStack(spacing: 10) {
                // Facebook Row
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "hand.thumbsup.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Facebook: Learn to Developer")
                            .font(.system(size: 13, weight: .semibold))
                        Text("https://www.facebook.com/learntodeveloper")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if let url = URL(string: "https://www.facebook.com/learntodeveloper") {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Text("เปิดเพจ")
                                    .font(.system(size: 11.5, weight: .medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.secondary.opacity(0.06)))

                // Donate / Buy Me a Coffee Row
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("โดเนท หรือ Buy Me a Coffee (พร้อมเพย์)")
                            .font(.system(size: 13, weight: .semibold))
                        Text("0959201930")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Button(action: {
                        let pb = NSPasteboard.general
                        pb.clearContents()
                        pb.setString("0959201930", forType: .string)
                        HapticManager.shared.playClick()
                        withAnimation(.spring(response: 0.25)) {
                            isCopiedDonate = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.spring(response: 0.25)) {
                                isCopiedDonate = false
                            }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isCopiedDonate ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 10.5, weight: .semibold))
                            Text(isCopiedDonate ? "คัดลอกแล้ว!" : "คัดลอกเบอร์")
                                .font(.system(size: 11.5, weight: .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(isCopiedDonate ? Color.green.opacity(0.16) : Color.orange.opacity(0.12))
                        .foregroundColor(isCopiedDonate ? .green : .orange)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.secondary.opacity(0.06)))
            }
        }
    }
}
