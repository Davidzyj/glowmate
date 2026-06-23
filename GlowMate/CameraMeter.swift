import AVFoundation
import CoreImage
import Photos
import SwiftUI

final class CameraMeter: NSObject, ObservableObject {
    enum PermissionState {
        case unknown
        case denied
        case authorized
    }

    enum PhotoCaptureError: Error {
        case cameraDenied
        case cameraUnavailable
        case captureUnavailable
        case captureFailed
        case photoDataUnavailable
        case photosDenied
        case saveFailed
    }

    @Published var permissionState: PermissionState = .unknown
    @Published var sample: LightingSample = .neutral
    @Published var isCapturingPhoto = false

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "GlowMate.camera.session")
    private let outputQueue = DispatchQueue(label: "GlowMate.camera.output")
    private var isConfigured = false
    private var photoProcessors: [Int64: PhotoCaptureProcessor] = [:]

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

    func captureAndSave(completion: @escaping (Result<Void, PhotoCaptureError>) -> Void) {
        guard permissionState == .authorized else {
            DispatchQueue.main.async {
                completion(.failure(.cameraDenied))
            }
            return
        }

        guard !isCapturingPhoto else {
            return
        }

        isCapturingPhoto = true

        sessionQueue.async { [weak self] in
            guard let self else { return }

            if !self.isConfigured {
                self.configureSession()
            }

            guard self.isConfigured else {
                self.finishPhotoCapture(id: nil, result: .failure(.cameraUnavailable), completion: completion)
                return
            }

            guard self.session.outputs.contains(self.photoOutput) else {
                self.finishPhotoCapture(id: nil, result: .failure(.captureUnavailable), completion: completion)
                return
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }

            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .balanced

            let processor = PhotoCaptureProcessor { [weak self] result in
                self?.finishPhotoCapture(id: settings.uniqueID, result: result, completion: completion)
            }
            self.photoProcessors[settings.uniqueID] = processor
            self.photoOutput.capturePhoto(with: settings, delegate: processor)
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

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

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .balanced
        }

        session.commitConfiguration()
        isConfigured = true
    }

    private func finishPhotoCapture(
        id: Int64?,
        result: Result<Void, PhotoCaptureError>,
        completion: @escaping (Result<Void, PhotoCaptureError>) -> Void
    ) {
        if let id {
            sessionQueue.async { [weak self] in
                self?.photoProcessors[id] = nil
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.isCapturingPhoto = false
            completion(result)
        }
    }
}

private final class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Result<Void, CameraMeter.PhotoCaptureError>) -> Void

    init(completion: @escaping (Result<Void, CameraMeter.PhotoCaptureError>) -> Void) {
        self.completion = completion
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            completion(.failure(.captureFailed))
            return
        }

        guard let photoData = photo.fileDataRepresentation() else {
            completion(.failure(.photoDataUnavailable))
            return
        }

        PhotoLibraryWriter.savePhoto(data: photoData, completion: completion)
    }
}

private enum PhotoLibraryWriter {
    static func savePhoto(data: Data, completion: @escaping (Result<Void, CameraMeter.PhotoCaptureError>) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                completion(.failure(.photosDenied))
                return
            }

            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, _ in
                completion(success ? .success(()) : .failure(.saveFailed))
            }
        }
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
