import AppKit
import CoreImage

public enum PromptPayQRGenerator {
    /// Generates standard EMVCo PromptPay QR Code payload string for Thai mobile numbers
    public static func generatePayload(mobile: String) -> String {
        let digits = mobile.filter { $0.isNumber }
        let formattedMobile: String
        if digits.hasPrefix("0") {
            formattedMobile = "0066" + digits.dropFirst()
        } else if digits.hasPrefix("66") {
            formattedMobile = "00" + digits
        } else {
            formattedMobile = digits
        }

        let tag29Sub = "0016A000000677010111" + String(format: "01%02d%@", formattedMobile.count, formattedMobile)
        let tag29 = String(format: "29%02d%@", tag29Sub.count, tag29Sub)
        let payloadNoCRC = "000201010211\(tag29)53037645802TH6304"
        let crc = crc16(payloadNoCRC)
        return payloadNoCRC + crc
    }

    /// Generates an ultra-crisp NSImage QR code
    public static func generateQRCodeImage(mobile: String, size: CGFloat = 200) -> NSImage? {
        let payload = generatePayload(mobile: mobile)
        guard let data = payload.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }

        let extent = output.extent
        guard extent.width > 0, extent.height > 0 else { return nil }
        let scale = size / extent.width
        let transformed = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let rep = NSCIImageRep(ciImage: transformed)
        let image = NSImage(size: NSSize(width: size, height: size))
        image.addRepresentation(rep)
        return image
    }

    private static func crc16(_ data: String) -> String {
        var crc: UInt16 = 0xFFFF
        for byte in data.utf8 {
            crc ^= (UInt16(byte) << 8)
            for _ in 0..<8 {
                if (crc & 0x8000) != 0 {
                    crc = ((crc << 1) ^ 0x1021) & 0xFFFF
                } else {
                    crc = (crc << 1) & 0xFFFF
                }
            }
        }
        return String(format: "%04X", crc)
    }
}
