import AppKit
import SwiftUI

public struct FolderDetailView: View {
    @ObservedObject var folder: FolderItem
    @ObservedObject var scanner: AppScanner = .shared
    @ObservedObject var settings: AppSettings = .shared
    public let onLaunch: (AppItem) -> Void
    public let onClose: () -> Void

    @State private var draggingApp: AppItem? = nil
    @State private var dragPosition: CGPoint = .zero
    @State private var isOutsideFolder: Bool = false
    @State private var folderBoxRect: CGRect = .zero

    private var columnCount: Int {
        let count = folder.apps.count
        if count <= 9 {
            return 3
        } else {
            return 4
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(settings.iconSize + 36), spacing: 18), count: columnCount)
    }

    private var cardWidth: CGFloat {
        let cols = CGFloat(columnCount)
        let itemWidth = settings.iconSize + 36
        let totalSpacing = (cols - 1) * 18
        return cols * itemWidth + totalSpacing + 64
    }

    public init(
        folder: FolderItem,
        onLaunch: @escaping (AppItem) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.folder = folder
        self.onLaunch = onLaunch
        self.onClose = onClose
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Dark Backdrop to capture clicks outside and drops to ungroup
                Color.black.opacity(isOutsideFolder ? 0.65 : 0.50)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if draggingApp == nil {
                            onClose()
                        }
                    }

                // 2. Drop Outside Visual Banner Indicator
                if isOutsideFolder {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                                .font(.system(size: 16, weight: .semibold))
                            Text("ปล่อยตรงนี้เพื่อนำออกจากกลุ่ม")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.95))
                                .shadow(color: Color.accentColor.opacity(0.55), radius: 14, x: 0, y: 5)
                        )
                        .padding(.bottom, 60)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }

                // 3. Folder Container Box
                VStack(spacing: 16) {
                    // Header Bar: Folder Name & Close Button
                    HStack {
                        Spacer()

                        // Editable Folder Title
                        TextField("ชื่อโฟลเดอร์", text: $folder.name)
                            .textFieldStyle(.plain)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                            )
                            .frame(maxWidth: 280)
                            .onSubmit {
                                scanner.renameFolder(folderId: folder.id, newName: folder.name)
                            }

                        Spacer()
                    }
                    .overlay(alignment: .trailing) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white.opacity(0.75))
                                .padding(7)
                                .background(Circle().fill(Color.white.opacity(0.18)))
                        }
                        .buttonStyle(.plain)
                        .help("ปิดโฟลเดอร์ (Esc)")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Apps Inside Folder Grid
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(folder.apps) { app in
                                let isBeingDragged = draggingApp?.path == app.path

                                AppItemView(
                                    app: app,
                                    isHighlightedTarget: false,
                                    isBeingDragged: isBeingDragged
                                )
                                .opacity(isBeingDragged ? 0.25 : 1.0)
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .named("FolderDetailSpace"))
                                        .onChanged { value in
                                            let dist = hypot(value.translation.width, value.translation.height)
                                            if dist >= 6 {
                                                if draggingApp == nil {
                                                    draggingApp = app
                                                }
                                                dragPosition = value.location

                                                // Check if drag position is outside folder card
                                                let expandedBounds = folderBoxRect.insetBy(dx: -30, dy: -30)
                                                withAnimation(.spring(response: 0.2)) {
                                                    isOutsideFolder = !expandedBounds.contains(value.location)
                                                }
                                            }
                                        }
                                        .onEnded { value in
                                            let dist = hypot(value.translation.width, value.translation.height)
                                            if dist < 6 {
                                                // Click -> launch
                                                onLaunch(app)
                                            } else if isOutsideFolder {
                                                // Drop outside -> ungroup
                                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                    scanner.removeAppFromFolder(appPath: app.path, folderId: folder.id)
                                                }
                                            }

                                            withAnimation(.spring(response: 0.25)) {
                                                draggingApp = nil
                                                isOutsideFolder = false
                                            }
                                        }
                                )
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                    }
                    .frame(maxHeight: min(geometry.size.height * 0.62, 480))

                    // Footer Hint
                    HStack(spacing: 8) {
                        Text("\(folder.apps.count) แอพ • ลากไอคอนออกไปข้างนอกเพื่อนำออกจากกลุ่ม")
                            .font(.system(size: 11.5, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    .padding(.bottom, 16)
                }
                .frame(width: min(geometry.size.width - 60, max(420, cardWidth)))
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                folderBoxRect = geo.frame(in: .named("FolderDetailSpace"))
                            }
                            .onChange(of: geo.frame(in: .named("FolderDetailSpace"))) { _, newFrame in
                                folderBoxRect = newFrame
                            }
                    }
                )
                .background(
                    ZStack {
                        // Deep frosted glass effect
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                        Color.black.opacity(0.48)
                    }
                    .cornerRadius(28)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.24), lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.65), radius: 36, x: 0, y: 18)
                .padding(30)

                // 4. Floating Drag Preview
                if let dragged = draggingApp {
                    VStack(spacing: 8) {
                        Image(nsImage: dragged.icon)
                            .resizable()
                            .interpolation(.high)
                            .antialiased(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: settings.iconSize * 1.15, height: settings.iconSize * 1.15)
                            .shadow(color: Color.black.opacity(0.65), radius: 18, x: 0, y: 10)

                        Text(dragged.name)
                            .font(.system(size: 12.5, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.9), radius: 4, x: 0, y: 2)
                            .lineLimit(1)
                    }
                    .frame(width: settings.iconSize + 50, height: settings.iconSize + 55)
                    .position(dragPosition)
                    .allowsHitTesting(false)
                    .zIndex(999)
                }
            }
            .coordinateSpace(name: "FolderDetailSpace")
        }
        .transition(.scale(scale: 0.94).combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isOutsideFolder)
    }
}
