import AppKit
import SwiftUI

public struct AppQuickLookView: View {
    public let app: AppItem
    public let onClose: () -> Void
    public let onLaunch: () -> Void

    @ObservedObject private var scanner: AppScanner = .shared
    @State private var versionString: String = "กำลังตรวจสอบ..."
    @State private var architectureString: String = "กำลังตรวจสอบ..."
    @State private var fileSizeString: String = "กำลังคำนวณ..."
    @State private var bundleIDString: String = ""

    public init(
        app: AppItem,
        onClose: @escaping () -> Void,
        onLaunch: @escaping () -> Void
    ) {
        self.app = app
        self.onClose = onClose
        self.onLaunch = onLaunch
    }

    private var isRunning: Bool {
        scanner.isRunning(app: app)
    }

    public var body: some View {
        ZStack {
            // Background Dimming & Tap-to-dismiss
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onClose()
                }

            // Quick Look Card
            VStack(spacing: 0) {
                // Header Bar with Close Button
                HStack(alignment: .top, spacing: 16) {
                    // App Icon
                    Image(nsImage: app.icon)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 68, height: 68)
                        .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name)
                            .font(.system(size: 19, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(versionString)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))

                        HStack(spacing: 6) {
                            // Category Badge
                            HStack(spacing: 4) {
                                Image(systemName: app.category.iconName)
                                    .font(.system(size: 10))
                                Text(app.category.displayName)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.white.opacity(0.15)))
                            .foregroundColor(.white.opacity(0.9))

                            // Running Status Badge
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(isRunning ? Color.green : Color.white.opacity(0.4))
                                    .frame(width: 6, height: 6)
                                Text(isRunning ? "กำลังทำงาน" : "ไม่ได้เปิด")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(isRunning ? Color.green.opacity(0.18) : Color.white.opacity(0.1)))
                            .foregroundColor(isRunning ? Color.green : Color.white.opacity(0.75))
                        }
                        .padding(.top, 2)
                    }

                    Spacer()

                    // Close (X) Button
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(7)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)

                Divider()
                    .background(Color.white.opacity(0.12))

                // Detail Specs Grid
                VStack(spacing: 10) {
                    detailRow(title: "สถาปัตยกรรม (Arch)", value: architectureString, icon: "cpu")
                    detailRow(title: "ขนาดไฟล์ (Size)", value: fileSizeString, icon: "internaldrive")
                    detailRow(title: "ที่อยู่ไฟล์ (Path)", value: app.path, icon: "folder")
                    if !bundleIDString.isEmpty {
                        detailRow(title: "Bundle ID", value: bundleIDString, icon: "tag")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                Divider()
                    .background(Color.white.opacity(0.12))

                // Action Buttons Footer
                HStack(spacing: 12) {
                    // Show in Finder
                    Button(action: {
                        onClose()
                        NSWorkspace.shared.activateFileViewerSelecting([app.url])
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.badge.gearshape")
                                .font(.system(size: 12))
                            Text("แสดงใน Finder")
                                .font(.system(size: 12.5, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.12)))
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    // Open / Switch to App
                    Button(action: onLaunch) {
                        HStack(spacing: 6) {
                            Image(systemName: isRunning ? "arrow.triangle.2.circlepath" : "play.fill")
                                .font(.system(size: 11))
                            Text(isRunning ? "สลับไปยังแอป" : "เปิดแอปพลิเคชัน")
                                .font(.system(size: 12.5, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.accentColor))
                        .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.defaultAction)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .frame(width: 460)
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
            )
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.6), radius: 30, x: 0, y: 15)
        }
        .onAppear {
            loadMetadata()
        }
    }

    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: 16)

            Text(title)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 130, alignment: .leading)

            Text(value)
                .font(.system(size: 11.5, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()
        }
    }

    private func loadMetadata() {
        bundleIDString = app.bundleIdentifier ?? ""

        if let bundle = Bundle(url: app.url) {
            // Version & Build
            let ver = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? ""
            if !ver.isEmpty && !build.isEmpty && ver != build {
                versionString = "เวอร์ชัน \(ver) (Build \(build))"
            } else if !ver.isEmpty {
                versionString = "เวอร์ชัน \(ver)"
            } else if !build.isEmpty {
                versionString = "Build \(build)"
            } else {
                versionString = "ไม่ระบุเวอร์ชัน"
            }

            // Architecture
            if let archs = bundle.executableArchitectures {
                let types = archs.map { $0.intValue }
                let hasArm = types.contains(16777228) // CPU_TYPE_ARM64
                let hasX86 = types.contains(16777223) // CPU_TYPE_X86_64
                if hasArm && hasX86 {
                    architectureString = "Universal (Apple Silicon & Intel)"
                } else if hasArm {
                    architectureString = "Apple Silicon Native (arm64)"
                } else if hasX86 {
                    architectureString = "Intel 64-bit (x86_64)"
                } else {
                    architectureString = "macOS Native"
                }
            } else {
                architectureString = "macOS Application"
            }
        } else {
            versionString = "แอปพลิเคชัน"
            architectureString = "macOS Native"
        }

        // Asynchronous File Size Calculation
        let targetURL = app.url
        let targetPath = app.path

        Task.detached(priority: .userInitiated) {
            var totalSize: Int64 = 0
            let fileManager = FileManager.default
            if let enumerator = fileManager.enumerator(
                at: targetURL,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            ) {
                while let fileURL = enumerator.nextObject() as? URL {
                    if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                        totalSize += Int64(size)
                    }
                }
            }
            if totalSize == 0 {
                if let attr = try? fileManager.attributesOfItem(atPath: targetPath),
                   let s = attr[.size] as? Int64 {
                    totalSize = s
                }
            }
            let formatted = ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
            await MainActor.run {
                self.fileSizeString = formatted
            }
        }
    }
}
