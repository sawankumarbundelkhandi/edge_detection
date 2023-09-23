//
//  CameraScannerViewController.swift
//  WeScan
//
//  Created by Chawatvish Worrapoj on 6/1/2020
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import AVFoundation
import UIKit

/// A set of methods that your delegate object must implement to get capture image.
/// If camera module doesn't work it will send error back to your delegate object.
public protocol CameraScannerViewOutputDelegate: AnyObject {
    func captureImageFailWithError(error: Error)
    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?)
}

/// A view controller that manages the camera module and auto capture of rectangle shape of document
/// The `CameraScannerViewController` class is individual camera view include touch for focus, flash control,
/// capture control and auto detect rectangle shape of object.
public final class CameraScannerViewController: UIViewController {

    /// The status of auto scan.
    public var isAutoScanEnabled: Bool = CaptureSession.current.isAutoScanEnabled {
        didSet {
            CaptureSession.current.isAutoScanEnabled = isAutoScanEnabled
        }
    }

    /// The callback to caller view to send back success or fail.
    public weak var delegate: CameraScannerViewOutputDelegate?

    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()

    /// The view that shows the focus rectangle (when the user taps to focus, similar to the Camera app)
    private var focusRectangle: FocusRectangleView!

    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()

    /// Whether flash is enabled
    private var flashEnabled = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoPreviewLayer.frame = view.layer.bounds
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        captureSessionManager?.stop()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }

    private func setupView() {
        view.backgroundColor = .darkGray
        view.layer.addSublayer(videoPreviewLayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(quadView)
        setupConstraints()

        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer)
        captureSessionManager?.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subjectAreaDidChange),
            name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange,
            object: nil
        )
    }

    private func setupConstraints() {
        var quadViewConstraints = [NSLayoutConstraint]()

        quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: view.topAnchor),
            view.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: quadView.trailingAnchor),
            quadView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ]
        NSLayoutConstraint.activate(quadViewConstraints)
    }

    /// Called when the AVCaptureDevice detects that the subject area has changed significantly. When it's called,
    /// we reset the focus so the camera is no longer out of focus.
    @objc private func subjectAreaDidChange() {
        /// Reset the focus and exposure back to automatic
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }

        /// Remove the focus rectangle if one exists
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard  let touch = touches.first else { return }
        let touchPoint = touch.location(in: view)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)

        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)

        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
        focusRectangle.setBorder(color: UIColor.white.cgColor)
        view.addSubview(focusRectangle)

        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
    }

    public func capture() {
        captureSessionManager?.capturePhoto()
    }

    public func toggleFlash() {
        let state = CaptureSession.current.toggleFlash()
        switch state {
        case .on:
            flashEnabled = true
        case .off:
            flashEnabled = false
        case .unknown, .unavailable:
            flashEnabled = false
        }
    }

    public func toggleAutoScan() {
        isAutoScanEnabled.toggle()
    }
}

extension CameraScannerViewController: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        delegate?.captureImageFailWithError(error: error)
    }

    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        captureSessionManager.stop()
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager,
                               didCapturePicture picture: UIImage,
                               withQuad quad: Quadrilateral?) {
        delegate?.captureImageSuccess(image: picture, withQuad: quad)
    }

    func captureSessionManager(_ captureSessionManager: CaptureSessionManager,
                               didDetectQuad quad: Quadrilateral?,
                               _ imageSize: CGSize) {
        guard let quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }

        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)
        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        let transformedQuad = quad.applyTransforms(transforms)
        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }
}
