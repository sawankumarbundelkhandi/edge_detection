//
//  EditImageViewController.swift
//  WeScan
//
//  Created by Chawatvish Worrapoj on 7/1/2020
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import AVFoundation
import UIKit

/// A protocol that your delegate object will get results of EditImageViewController.
public protocol EditImageViewDelegate: AnyObject {
    /// A method that your delegate object must implement to get cropped image.
    func cropped(image: UIImage)
}

/// A view controller that manages edit image for scanning documents or pick image from photo library
/// The `EditImageViewController` class is individual for rotate, crop image
public final class EditImageViewController: UIViewController {

    /// The image the quadrilateral was detected on.
    private var image: UIImage

    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral
    private var zoomGestureController: ZoomGestureController!
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    public weak var delegate: EditImageViewDelegate?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.strokeColor = strokeColor
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()

    private var strokeColor: CGColor?

    // MARK: - Life Cycle

    public init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true, strokeColor: CGColor? = nil) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = quad ?? EditImageViewController.defaultQuad(allOfImage: image)
        self.strokeColor = strokeColor
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        addLongGesture(of: zoomGestureController)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }

    // MARK: - Setups

    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(quadView)
    }

    private func setupConstraints() {
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)

        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]

        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
    }

    private func addLongGesture(of controller: ZoomGestureController) {
        let touchDown = UILongPressGestureRecognizer(target: controller,
                                                     action: #selector(controller.handle(pan:)))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }

    // MARK: - Actions
    /// This function allow user can crop image follow quad. the image will send back by delegate function
    public func cropImage() {
        guard let quad = quadView.quad, let ciImage = CIImage(image: image) else {
            return
        }

        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        delegate?.cropped(image: croppedImage)
    }

    /// This function allow user to rotate image by 90 degree each and will reload image on image view.
    public func rotateImage() {
        let rotationAngle = Measurement<UnitAngle>(value: 90, unit: .degrees)
        reloadImage(withAngle: rotationAngle)
    }

    private func reloadImage(withAngle angle: Measurement<UnitAngle>) {
        guard let newImage = image.rotated(by: angle) else { return }
        let newQuad = EditImageViewController.defaultQuad(allOfImage: newImage)

        image = newImage
        imageView.image = image
        quad = newQuad
        adjustQuadViewConstraints()
        displayQuad()

        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        addLongGesture(of: zoomGestureController)
    }

    private func displayQuad() {
        let imageSize = image.size
        let size = CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant)
        let imageFrame = CGRect(origin: quadView.frame.origin, size: size)

        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyTransforms(transforms)

        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }

    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints
    /// to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }

    /// Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)

        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        return quad
    }

    /// Generates a `Quadrilateral` object that's cover all of image.
    private static func defaultQuad(allOfImage image: UIImage, withOffset offset: CGFloat = 75) -> Quadrilateral {
        let topLeft = CGPoint(x: offset, y: offset)
        let topRight = CGPoint(x: image.size.width - offset, y: offset)
        let bottomRight = CGPoint(x: image.size.width - offset, y: image.size.height - offset)
        let bottomLeft = CGPoint(x: offset, y: image.size.height - offset)
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        return quad
    }
}
