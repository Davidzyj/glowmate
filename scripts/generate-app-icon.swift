import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import Foundation

struct IconSize {
    let filename: String
    let pixels: Int
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDir = root.appendingPathComponent("GlowMate/Assets.xcassets/AppIcon.appiconset")

let sizes = [
    IconSize(filename: "AppIcon-20@2x.png", pixels: 40),
    IconSize(filename: "AppIcon-20@3x.png", pixels: 60),
    IconSize(filename: "AppIcon-29@2x.png", pixels: 58),
    IconSize(filename: "AppIcon-29@3x.png", pixels: 87),
    IconSize(filename: "AppIcon-40@2x.png", pixels: 80),
    IconSize(filename: "AppIcon-40@3x.png", pixels: 120),
    IconSize(filename: "AppIcon-60@2x.png", pixels: 120),
    IconSize(filename: "AppIcon-60@3x.png", pixels: 180),
    IconSize(filename: "AppIcon-1024.png", pixels: 1024)
]

func drawIcon(size: Int) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: size * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else {
        fatalError("Unable to create bitmap context")
    }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)

    context.setFillColor(CGColor(red: 1.0, green: 0.957, blue: 0.902, alpha: 1))
    context.fill(rect)

    let background = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 0.38, blue: 0.31, alpha: 1),
            CGColor(red: 1.0, green: 0.73, blue: 0.30, alpha: 1)
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawLinearGradient(
        background,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: []
    )

    let glowCenter = CGPoint(x: CGFloat(size) * 0.50, y: CGFloat(size) * 0.49)
    let glowRadius = CGFloat(size) * 0.44
    let glow = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 0.98, blue: 0.86, alpha: 0.98),
            CGColor(red: 1.0, green: 0.82, blue: 0.54, alpha: 0.48),
            CGColor(red: 1.0, green: 0.45, blue: 0.34, alpha: 0.0)
        ] as CFArray,
        locations: [0.0, 0.58, 1.0]
    )!
    context.drawRadialGradient(
        glow,
        startCenter: glowCenter,
        startRadius: 0,
        endCenter: glowCenter,
        endRadius: glowRadius,
        options: []
    )

    let ringRect = rect.insetBy(dx: CGFloat(size) * 0.19, dy: CGFloat(size) * 0.19)
    context.setLineWidth(CGFloat(size) * 0.085)
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.96))
    context.strokeEllipse(in: ringRect)

    let innerRing = rect.insetBy(dx: CGFloat(size) * 0.30, dy: CGFloat(size) * 0.30)
    context.setLineWidth(CGFloat(size) * 0.026)
    context.setStrokeColor(CGColor(red: 1.0, green: 0.93, blue: 0.70, alpha: 0.90))
    context.strokeEllipse(in: innerRing)

    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.98))
    func diamond(center: CGPoint, radius: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x, y: center.y + radius))
        path.addLine(to: CGPoint(x: center.x + radius * 0.38, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y - radius))
        path.addLine(to: CGPoint(x: center.x - radius * 0.38, y: center.y))
        path.closeSubpath()
        context.addPath(path)
        context.fillPath()
    }

    diamond(center: CGPoint(x: CGFloat(size) * 0.68, y: CGFloat(size) * 0.68), radius: CGFloat(size) * 0.095)
    diamond(center: CGPoint(x: CGFloat(size) * 0.32, y: CGFloat(size) * 0.33), radius: CGFloat(size) * 0.052)

    let faceRect = CGRect(
        x: CGFloat(size) * 0.39,
        y: CGFloat(size) * 0.37,
        width: CGFloat(size) * 0.22,
        height: CGFloat(size) * 0.28
    )
    context.setStrokeColor(CGColor(red: 0.43, green: 0.20, blue: 0.15, alpha: 0.28))
    context.setLineWidth(CGFloat(size) * 0.018)
    context.strokeEllipse(in: faceRect)

    guard let image = context.makeImage() else {
        fatalError("Unable to create image")
    }
    return image
}

func savePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        fatalError("Unable to create image destination")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        fatalError("Unable to write \(url.lastPathComponent)")
    }
}

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

for icon in sizes {
    let image = drawIcon(size: icon.pixels)
    try savePNG(image, to: outputDir.appendingPathComponent(icon.filename))
    print("Wrote \(icon.filename) \(icon.pixels)x\(icon.pixels)")
}
