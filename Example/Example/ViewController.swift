//
//  ViewController.swift
//  Example
//
//  Created by Roman Mazeev on 28.06.2021.
//

import UIKit
import AVFoundation
import MRZScanner
import MRZParser

class ViewController: UIViewController {
    // MARK: UI objects
    private let previewView = PreviewView()
    private let cutoutView = UIView()
    private let maskLayer = CAShapeLayer()

    // MARK: Scanning related
    private let scanner = LiveMRZScanner()
    private var scanningIsEnabled = true {
        didSet {
            scanningIsEnabled ? captureSession.startRunning() : captureSession.stopRunning()

            if !scanningIsEnabled {
                removeBoxes()
                scanner.resetLiveScanningSession()
            }
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: Capture related objects
    private let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "com.aita.mrzExample.captureSessionQueue")

    private var captureDevice: AVCaptureDevice?

    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "com.aita.mrzExample.videoDataOutputQueue")

    /// Device orientation. Updated whenever the orientation changes to a different supported orientation.
    private var currentOrientation = UIDeviceOrientation.portrait

    private func checkCaptureDeviceAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        default:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else { fatalError("To work, you need to give access to the camera.") }
                return
            }
        }
    }

    // MARK: Region of interest (ROI) and text orientation
    // Region of video data output buffer that recognition should be run on.
    // Gets recalculated once the bounds of the preview layer are known.
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    // Orientation of text to search for in the region of interest.
    var textOrientation = CGImagePropertyOrientation.up

    // MARK: Coordinate transforms
    var bufferAspectRatio: Double!
    // Transform from UI orientation to buffer orientation.
    var uiRotationTransform = CGAffineTransform.identity
    // Transform bottom-left coordinates to top-left.
    var bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    // Transform coordinates in ROI to global coordinates (still normalized).
    var roiToGlobalTransform = CGAffineTransform.identity

    // Vision -> AVF coordinate transform.
    var visionToAVFTransform = CGAffineTransform.identity

    // MARK: View controller methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        checkCaptureDeviceAuthorization()

        // Set up preview view.
        previewView.session = captureSession
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // Set up cutout view.
        cutoutView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        cutoutView.layer.mask = maskLayer

        // Starting the capture session is a blocking call. Perform setup using
        // a dedicated serial dispatch queue to prevent blocking the main thread.
        captureSessionQueue.async {
            self.setupCamera()

            // Calculate region of interest now that the camera is setup.
            DispatchQueue.main.async {
                // Figure out initial ROI.
                self.calculateRegionOfInterest()
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Only change the current orientation if the new one is landscape or
        // portrait. You can't really do anything about flat or unknown.
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape {
            currentOrientation = deviceOrientation
        }

        // Handle device orientation in the preview layer.
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            if let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) {
                videoPreviewLayerConnection.videoOrientation = newVideoOrientation
            }
        }

        // Orientation changed: figure out new region of interest (ROI).
        calculateRegionOfInterest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCutout()
    }

    // MARK: Setup
    private func setup() {
        view.insetsLayoutMarginsFromSafeArea = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        cutoutView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        view.addSubview(cutoutView)

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cutoutView.topAnchor.constraint(equalTo: view.topAnchor),
            cutoutView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cutoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cutoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func calculateRegionOfInterest() {
        // In landscape orientation the desired ROI is specified as the ratio of
        // buffer width to height. When the UI is rotated to portrait, keep the
        // vertical size the same (in buffer pixels). Also try to keep the
        // horizontal size the same up to a maximum ratio.
        let desiredHeightRatio = 0.15
        let desiredWidthRatio = 0.6
        let maxPortraitWidth = 0.8

        // Figure out size of ROI.
        let size: CGSize
        if currentOrientation.isPortrait || currentOrientation == .unknown {
            size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth),
                          height: desiredHeightRatio / bufferAspectRatio)
        } else {
            size = CGSize(width: desiredWidthRatio, height: desiredHeightRatio)
        }
        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size

        // ROI changed, update transform.
        setupOrientationAndTransform()

        // Update the cutout to match the new ROI.
        DispatchQueue.main.async {
            // Wait for the next run cycle before updating the cutout. This
            // ensures that the preview layer already has its new orientation.
            self.updateCutout()
        }
    }

    private func updateCutout() {
        // Figure out where the cutout ends up in layer coordinates.
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = previewView.videoPreviewLayer.layerRectConverted(
            fromMetadataOutputRect: regionOfInterest
                .applying(roiRectTransform)
        )

        // Create the mask.
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer.path = path.cgPath
    }

    private func setupOrientationAndTransform() {
        // Recalculate the affine transform between Vision coordinates and AVF coordinates.

        // Compensate for region of interest.
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x,
                                                 y: roi.origin.y)
            .scaledBy(x: roi.width, y: roi.height)

        // Compensate for orientation (buffers always come in the same orientation).
        switch currentOrientation {
        case .landscapeLeft:
            textOrientation = CGImagePropertyOrientation.up
            uiRotationTransform = CGAffineTransform.identity
        case .landscapeRight:
            textOrientation = CGImagePropertyOrientation.down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
        case .portraitUpsideDown:
            textOrientation = CGImagePropertyOrientation.left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        default: // We default everything else to .portraitUp
            textOrientation = CGImagePropertyOrientation.right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }

        // Full Vision ROI to AVF transform.
        visionToAVFTransform = roiToGlobalTransform
            .concatenating(bottomToTopTransform)
            .concatenating(uiRotationTransform)
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: AVMediaType.video,
                                                          position: .back) else {
            fatalError("Could not create capture device.")
        }
        self.captureDevice = captureDevice

        // NOTE:
        // Requesting 4k buffers allows recognition of smaller text but will
        // consume more power. Use the smallest buffer size necessary to keep
        // down battery usage.
        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            fatalError("Could not create device input.")
        }

        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }

        // Configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // NOTE:
            // There is a trade-off to be made here. Enabling stabilization will
            // give temporally more stable results and should help the recognizer
            // converge. But if it's enabled the VideoDataOutput buffers don't
            // match what's displayed on screen, which makes drawing bounding
            // boxes very hard. Disable it in this app to allow drawing detected
            // bounding boxes on screen.
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            fatalError("Could not add VDO output")
        }

        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 1.5
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            fatalError("Could not set zoom level due to error: \(error)")
        }

        captureSession.startRunning()
    }

    // MARK: Bounding box drawing

    private func showBoundingRects(valid validRects: [CGRect], invalid invalidRects: [CGRect]) {
        let layer = self.previewView.videoPreviewLayer
        self.removeBoxes()

        for rect in invalidRects {
            let rect = layer.layerRectConverted(fromMetadataOutputRect: rect.applying(visionToAVFTransform))
            self.draw(rect: rect, color: UIColor.red.cgColor)
        }
        for rect in validRects {
            let rect = layer.layerRectConverted(fromMetadataOutputRect: rect.applying(visionToAVFTransform))
            self.draw(rect: rect, color: UIColor.green.cgColor)
        }
    }

    // Draw a box on screen. Must be called from main queue.
    private var boxLayer = [CAShapeLayer]()
    private func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1
        layer.frame = rect
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }

    // Remove all drawn boxes. Must be called on main queue.
    private func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }

    // MARK: Alert displaying

    private func displayError(_ error: Error) {
        let alertController = UIAlertController(
            title: "Can't read MRZ code",
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        addAlertActionAndPresent(alertController)
    }

    private func displayMRZResult(_ result: MRZResult) {
        var birthdateString: String?
        var expiryDateString: String?


        if let birthdate = result.birthdate {
            birthdateString = dateFormatter.string(from: birthdate)
        }

        if let expiryDate = result.expiryDate {
            expiryDateString = dateFormatter.string(from: expiryDate)
        }

        let alertText = """
                        documentType: \(result.documentType)
                        countryCode: \(result.countryCode)
                        surnames: \(result.surnames)
                        givenNames: \(result.givenNames)
                        documentNumber: \(result.documentNumber ?? "-")
                        nationalityCountryCode: \(result.nationalityCountryCode)
                        birthdate: \(birthdateString ?? "-")
                        sex: \(result.sex)
                        expiryDate: \(expiryDateString ?? "-")
                        personalNumber: \(result.optionalData ?? "-")
                        personalNumber2: \(result.optionalData2 ?? "-")
                        """

        let alertController = UIAlertController(
            title: "MRZ scanned",
            message: alertText,
            preferredStyle: .alert
        )

        addAlertActionAndPresent(alertController)
    }

    private func addAlertActionAndPresent(_ alertController: UIAlertController) {
        alertController.addAction(.init(title: "OK", style: .cancel, handler: { [ unowned self ] _ in
            self.scanningIsEnabled = true
        }))

        if scanningIsEnabled {
            present(alertController, animated: true)
            scanningIsEnabled = false
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), scanningIsEnabled {
            scanner.scanFrame(
                pixelBuffer: pixelBuffer,
                orientation: textOrientation,
                regionOfInterest: regionOfInterest,
                minimumTextHeight: 0.1,
                foundBoundingRectsHandler: { [weak self] in
                    self?.showBoundingRects(valid: [], invalid: $0)
                },
                completionHandler: { [weak self] result in
                    switch result {
                    case .success(let scanningResult):
                        guard scanningResult.result.accuracy > 2 else { return }
                        self?.displayMRZResult(scanningResult.result.result)
                        self?.showBoundingRects(valid: scanningResult.boundingRects.valid, invalid:   scanningResult.boundingRects.invalid)
                    case .failure(let error):
                        self?.displayError(error)
                    }
                }
            )
        }
    }
}

// MARK: - Utility extensions

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        default:
            return nil
        }
    }
}
