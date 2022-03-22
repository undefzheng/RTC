//
//  VideoCapturerControl.swift
//  Demo_RTC
//
//  Created by apple on 2021/12/8.
//

import Foundation
import WebRTC

public class VideoCapturerControl {
    
    static let maxCaptureWidth: Int32 = 1280
    static let maxCaptureHeight: Int32 = 720
    static let maxCaptureFrameRate: Int32 = 30
    
    private let capturer = RTCCameraVideoCapturer()
    var capturerDelegate: RTCVideoCapturerDelegate? {
        set { capturer.delegate = newValue }
        get { capturer.delegate }
    }
    private let serialQueue = DispatchQueue(label: "org.rtc.videoCaptureController")
    private var isUsingFrontCamera: Bool = true
    private var isCapturing: Bool = false
    
    public var captureSession: AVCaptureSession {
        return capturer.captureSession
    }

    public init() {}

    public func startCapture() {
        serialQueue.sync { [weak self] in
            Logger.info("startCapture():")

            guard let strongSelf = self else {
                return
            }

            // Don't call startCapture if we're actively capturing.
            guard !strongSelf.isCapturing else { return }

            strongSelf.startCaptureSync()
        }
    }

    public func stopCapture() {
        serialQueue.sync { [weak self] in
            Logger.info("stopCapture():")

            guard let strongSelf = self else {
                return
            }

            // Don't call stopCapture unless we're actively capturing.
            // Calling this when we're not capturing will result in
            // a crash on iOS 13 when built with the iOS 13 SDK.
            guard strongSelf.isCapturing else { return }

            strongSelf.capturer.stopCapture()
            strongSelf.isCapturing = false
        }
    }
    
    public func switchCamera(isUsingFrontCamera: Bool) {
        serialQueue.sync { [weak self] in
            Logger.info("switchCamera():")

            guard let strongSelf = self else {
                return
            }

            // Only restart capturing again if the camera changes.
            if strongSelf.isUsingFrontCamera != isUsingFrontCamera {
                strongSelf.isUsingFrontCamera = isUsingFrontCamera
                strongSelf.startCaptureSync()
            }
        }
    }
    
    private func startCaptureSync() {
        Logger.info("startCaptureSync():")

        let position: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        guard let device: AVCaptureDevice = self.device(position: position) else {
            return
        }

        guard let format: AVCaptureDevice.Format = self.format(device: device) else {
            return
        }

        capturer.startCapture(with: device, format: format, fps: Int(VideoCapturerControl.maxCaptureFrameRate))
        isCapturing = true
    }
    
    private func device(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let captureDevices = RTCCameraVideoCapturer.captureDevices()
        guard let device = (captureDevices.first { $0.position == position }) else {
            Logger.debug("unable to find desired position: \(position)")
            return captureDevices.first
        }

        return device
    }
    
    private func getSubTypeString(pixelFormat: FourCharCode) -> String {
        let cString: [CChar] = [
            CChar(pixelFormat >> 24 & 0xFF),
            CChar(pixelFormat >> 16 & 0xFF),
            CChar(pixelFormat >> 8 & 0xFF),
            CChar(pixelFormat & 0xFF),
            0
        ]

        var subTypeString = ""

        cString.withUnsafeBufferPointer { ptr in
            subTypeString = String(cString: ptr.baseAddress!)
        }

        return subTypeString
    }
    
    private func format(device: AVCaptureDevice) -> AVCaptureDevice.Format? {
        let formats = RTCCameraVideoCapturer.supportedFormats(for: device)

        // For rendering, find a format that most closely matches the display size.
        // The local camera capture may be rendered full screen. However, make sure
        // the camera capture is at least our output size, which should be available
        // on all devices the client supports.
        let screenSize = UIScreen.main.nativeBounds.size
        let targetWidth = max(Int32(screenSize.width), VideoCapturerControl.maxCaptureWidth)
        let targetHeight = max(Int32(screenSize.height), VideoCapturerControl.maxCaptureHeight)
        let targetFrameRate = VideoCapturerControl.maxCaptureFrameRate

        Logger.info("Capture Formats")
        Logger.info("  screenSize:           \(screenSize)")
        Logger.info("  maxCaptureWidth:      \(VideoCapturerControl.maxCaptureWidth)")
        Logger.info("  maxCaptureHeight:     \(VideoCapturerControl.maxCaptureHeight)")
        Logger.info("  targetWidth:          \(targetWidth)")
        Logger.info("  targetHeight:         \(targetHeight)")
        Logger.info("  targetFrameRate:      \(targetFrameRate)")
        Logger.info("  formats:")

        var selectedFormat: AVCaptureDevice.Format?
        var currentDiff: Int32 = Int32.max

        for format in formats {
            let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);

            for range in format.videoSupportedFrameRateRanges {
                Logger.info("     width: \(dimension.width) height: \(dimension.height) fps range: \(range.minFrameRate) - \(range.maxFrameRate)")
            }

            let diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height)
            if diff < currentDiff {
                // Look through all framerate ranges for this capture format and find
                // the first that supports the desired framerate.
                for range in format.videoSupportedFrameRateRanges {
                    if Double(targetFrameRate) >= range.minFrameRate && Double(targetFrameRate) <= range.maxFrameRate {
                        selectedFormat = format
                        currentDiff = diff
                    }
                }
            }
        }
        
        if _isDebugAssertConfiguration(), let selectedFormat = selectedFormat {
            Logger.info("  selected: \(selectedFormat)")
        }
        
        return selectedFormat
    }
}
