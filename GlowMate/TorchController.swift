import AVFoundation
import Foundation

final class TorchController: ObservableObject {
    @Published var isOn = false
    @Published var isAvailable = false

    private var device: AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }

    init() {
        refreshAvailability()
    }

    func refreshAvailability() {
        isAvailable = device?.hasTorch == true
    }

    func setTorch(active: Bool, level: Double) {
        guard let device, device.hasTorch else {
            isAvailable = false
            isOn = false
            return
        }

        do {
            try device.lockForConfiguration()
            if active {
                let torchLevel = min(max(Float(level), 0.1), 1.0)
                try device.setTorchModeOn(level: torchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
            isOn = active
            isAvailable = true
        } catch {
            isOn = false
        }
    }
}
