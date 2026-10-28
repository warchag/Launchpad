# 🚀 Launchpad for macOS (Native Swift & SwiftUI)

แอปพลิเคชัน **Launchpad** แบบเนทีฟสำหรับ macOS ยุคใหม่ (macOS 14+ / macOS 26 / macOS 27+) พัฒนาด้วย Swift และ SwiftUI + AppKit ให้ความรู้สึกลื่นไหล สวยงามระดับ 120Hz ProMotion โดยไม่มีความหน่วง พร้อมดีไซน์ Frosted Glass / Glassmorphism ดั้งเดิมของ Apple

---

## ✨ คุณสมบัติเด่น (Features)

1. **ดีไซน์ Frosted Glass อิงจาก Desktop Wallpaper จริงแบบเบลอ**:
   - ดึงภาพวอลเปเปอร์หน้าจอที่ผู้ใช้กำลังใช้งานอยู่จริง (`Desktop Wallpaper`) มาประมวลผลเบลอ (Gaussian Blur) แบบเรียลไทม์
   - ปรับระดับความเบลอของภาพวอลเปเปอร์ได้ใน Settings (15px – 85px)
   - มีม่านลดแสงสะท้อน (Vignette Dimming) เพื่อให้ตัวอักษรสีขาวและไอคอนคมชัด อ่านง่าย สวยงามหรูหรา

2. **ระบบจัดหน้าและไอคอน (Classic Grid & Jiggle Mode)**:
   - ตารางแสดงแอปพลิเคชัน (เลือกได้ทั้ง 6x4, 7x5, 8x5, 8x6)
   - **โหมดจัดระเบียบสั่นดุ๊กดิ๊ก (Jiggle Edit Mode)**: คลิกปุ่มดินสอด้านล่าง หรือกดคลิกค้างที่ไอคอนแอป ➜ ไอคอนจะเริ่มสั่นดุ๊กดิ๊ก พร้อมขึ้นปุ่ม `(x)` เพื่อซ่อนหรือจัดการแอปได้อย่างสะดวกรวดเร็ว
   - สามารถปัด (Swipe) ด้วยแทร็คแพด, หมุนลูกกลิ้งเมาส์ (Scroll Wheel), หรือกดปุ่มลูกศร `←` / `→` เพื่อเปลี่ยนหน้า

3. **คลิกขวาที่ไอคอนแอป (Context Menu)**:
   - **Show in Finder**: เปิดดูตำแหน่งไฟล์แอปใน Finder ทันที
   - **Copy Path**: คัดลอก Path ของแอปไปยัง Clipboard
   - **Hide from Launchpad**: ซ่อนแอปที่ไม่ต้องการเห็น (เช่น Uninstallers หรือ Daemons)
   - **Move to Trash**: ย้ายแอปที่ไม่ต้องการลงถังขยะได้โดยตรง

4. **แถบแยกหมวดหมู่แอป (Category Pills)**:
   - มีแถบตัวกรองหมวดหมู่ด้านบน: **ทั้งหมด | การทำงาน | นักพัฒนา | เครื่องมือ | กราฟิกและสื่อ | โซเชียลและเว็บ | เกม | อื่นๆ**
   - จัดหมวดหมู่แอปอัตโนมัติตามประเภทจริงของ macOS

5. **แถบแอพเปิดล่าสุด (Recent Apps Shelf)**:
   - แสดงแถว 6 แอพที่เปิดใช้งานบ่อยหรือล่าสุดไว้บนสุดของหน้าแรก เพื่อให้คลิกเปิดทำงานต่อได้ทันที

6. **ระบบสร้างและจัดโฟลเดอร์ (App Folders & Grouping)**:
   - **สร้างโฟลเดอร์ใหม่:** คลิกค้างแล้วลากไอคอนแอปหนึ่งไปวางทับอีกแอปหนึ่ง จะรวมเป็นโฟลเดอร์ให้อัตโนมัติ (สไตล์ iOS / Launchpad ดั้งเดิม)
   - **ลากแอปออกจากโฟลเดอร์ (Ungroup):** เมื่อเปิดโฟลเดอร์ ให้ลากไอคอนแอปที่ต้องการออกมาปล่อยที่พื้นที่ว่างด้านนอก
   - **เปลี่ยนชื่อโฟลเดอร์:** คลิกที่ชื่อโฟลเดอร์ด้านบนเพื่อพิมพ์แก้ไขชื่อได้ทันที

7. **ระบบจัดการแอปที่ซ่อนไว้ (Hidden Apps Manager)**:
   - ซ่อนแอปขยะหรือเครื่องมือที่ไม่ต้องการเห็นจากหน้าจอหลัก
   - มีเมนูใน Settings ให้ตรวจสอบและกู้คืน (Unhide) แอปกลับมาได้ตลอดเวลา

8. **Hot Corner (สะบัดเมาส์ชนมุมจอเพื่อเปิด)**:
   - เลือกมุมหน้าจอที่ต้องการ (เช่น มุมซ้ายล่าง หรือขวาล่าง) เพื่อสะบัดเมาส์เปิด/ปิด Launchpad ได้ทันใจ

9. **การสั่นตอบสนอง (Haptic Feedback)**:
   - ตอบสนองด้วย Haptic สั่นเบาๆ บนแทร็คแพดเมื่อเปิดแอป เปลี่ยนหน้า หรือลากโฟลเดอร์ ให้สัมผัสที่สมจริงและพรีเมียม

10. **การเปิดใช้งานและปิด (Shortcuts & Dock Interaction)**:
    - **คลิกไอคอนใน Dock**: เปิด / ปิด Launchpad ได้ทันทีแบบไร้รอยต่อ
    - **Menu Bar Icon**: มีไอคอนรูปจรวด `🚀` ที่แถบเมนูด้านบน คลิกซ้ายเพื่อ Toggle หรือคลิกขวาเพื่อเปิดเมนูตั้งค่า
    - **การปิด**: กดปุ่ม `Escape` หรือคลิกพื้นที่ว่างบนหน้าจอ

---

## 🛠️ โครงสร้างโปรเจกต์

```
Launchpad/
├── Launchpad.app             # ตัวแอปที่คอมไพล์พร้อมใช้งาน
├── Package.swift             # Swift Package Manager Manifest
├── package_app.sh            # สคริปต์คอมไพล์ Release และ Pack เป็น .app
├── make_icon.py              # สคริปต์ประมวลผลไอคอน macOS Squircle
├── Resources/
│   ├── AppIcon.icns          # ไฟล์ไอคอนความละเอียดสูง
│   └── AppIcon.png
└── Sources/
    └── Launchpad/
        ├── main.swift
        ├── App/
        │   └── AppDelegate.swift
        ├── Models/
        │   ├── AppCategory.swift (in AppItem)
        │   ├── AppItem.swift
        │   ├── AppScanner.swift
        │   ├── AppSettings.swift
        │   ├── FolderItem.swift
        │   └── WallpaperManager.swift
        ├── Utils/
        │   ├── HapticManager.swift
        │   ├── HotCornerManager.swift
        │   └── HotKeyManager.swift
        ├── Views/
        │   ├── AppItemView.swift
        │   ├── FolderDetailView.swift
        │   ├── FolderItemView.swift
        │   ├── LaunchpadOverlayView.swift
        │   ├── PaginationView.swift
        │   ├── SearchBarView.swift
        │   ├── SettingsView.swift
        │   └── VisualEffectView.swift
        └── Window/
            ├── LaunchpadWindowController.swift
            └── SettingsWindowController.swift
```

---

## 🚀 วิธีนำไปปักไว้ที่ Dock

1. เปิด **Finder**
2. ไปที่โฟลเดอร์โปรเจกต์ หรือลาก **Launchpad.app** ไปไว้ที่ `/Applications`
3. ลาก **Launchpad.app** ลงมาวางที่ **Dock** ของคุณได้ทันที!
