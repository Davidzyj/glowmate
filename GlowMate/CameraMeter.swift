import AVFoundation
import CoreImage
import SwiftUI

final class CameraMeter: NSObject, ObservableObject {
    enum PermissionState {
        case unknown
        case denied
        case authorized
    }

    @Published var permissionState: PermissionState = .unknown
    @Published var sample: LightingSample = .neutral

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "GlowMate.camera.session")
    private let outputQueue = DispatchQueue(label: "GlowMate.camera.output")
    private var isConfigured = false

    override init() {
        super.init()
        refreshPermission()
    }

    func refreshPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionState = .authorized
        case .denied, .restricted:
            permissionState = .denied
        case .notDetermined:
            permissionState = .unknown
        @unknown default:
            permissionState = .denied
        }
    }

    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionState = granted ? .authorized : .denied
                if granted {
                    self?.start()
                }
            }
        }
    }

    func start() {
        guard permissionState == .authorized else {
            return
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.isConfigured {
                self.configureSession()
            }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .medium

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: outputQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
        isConfigured = true
    }
}

extension CameraMeter: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let measured = measure(pixelBuffer: pixelBuffer)
        DispatchQueue.main.async { [weak self] in
            self?.sample = measured
        }
    }

    private func measure(pixelBuffer: CVPixelBuffer) -> LightingSample {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return .neutral
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pointer = baseAddress.assumingMemoryBound(to: UInt8.self)
        let xStep = max(1, width / 24)
        let yStep = max(1, height / 24)

        var luminanceTotal = 0.0
        var centerTotal = 0.0
        var warmthTotal = 0.0
        var count = 0.0
        var centerCount = 0.0

        let centerRect = CGRect(x: Double(width) * 0.28, y: Double(height) * 0.20, width: Double(width) * 0.44, height: Double(height) * 0.48)

        for y in stride(from: 0, to: height, by: yStep) {
            for x in stride(from: 0, to: width, by: xStep) {
                let offset = y * bytesPerRow + x * 4
                let b = Double(pointer[offset]) / 255.0
                let g = Double(pointer[offset + 1]) / 255.0
                let r = Double(pointer[offset + 2]) / 255.0
                let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
                luminanceTotal += luminance
                warmthTotal += r - b
                count += 1

                if centerRect.contains(CGPoint(x: x, y: y)) {
                    centerTotal += luminance
                    centerCount += 1
                }
            }
        }

        guard count > 0 else {
            return .neutral
        }

        return LightingSample(
            luminance: luminanceTotal / count,
            warmth: warmthTotal / count,
            centerLuminance: centerCount > 0 ? centerTotal / centerCount : luminanceTotal / count
        )
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
