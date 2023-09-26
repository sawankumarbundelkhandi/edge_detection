//
//  ReviewViewControllerTests.swift
//  WeScanTests
//
//  Created by Julian Schiavo on 7/1/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//
//  swiftlint:disable line_length

import CoreGraphics
import SnapshotTesting
@testable import WeScan
import XCTest

final class ReviewViewControllerTests: XCTestCase {

    var demoScan: ImageScannerScan!
    var enhancedDemoScan: ImageScannerScan!
    var demoQuad = Quadrilateral(topLeft: .zero, topRight: .zero, bottomRight: .zero, bottomLeft: .zero)

    override func setUp() {
        super.setUp()

        // Set up the demo image using rectangles (purposefully made to be different on each rotation)
        let detailSize = CGSize(width: 20, height: 40)
        let detailLayer = CALayer()
        detailLayer.backgroundColor = UIColor.red.cgColor
        detailLayer.frame = CGRect(x: 30, y: 0, width: detailSize.width, height: detailSize.height)

        let backgroundSize = CGSize(width: 50, height: 120)
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UIColor.white.cgColor
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: backgroundSize.width, height: backgroundSize.height)
        backgroundLayer.addSublayer(detailLayer)

        UIGraphicsBeginImageContextWithOptions(backgroundSize, true, 1.0)
        backgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        demoScan = ImageScannerScan(image: image)

        backgroundLayer.backgroundColor = UIColor.black.cgColor
        backgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
        let enhancedImage = UIGraphicsGetImageFromCurrentImageContext()!
        enhancedDemoScan = ImageScannerScan(image: enhancedImage)

        UIGraphicsEndImageContext()
    }

    func testDemoImageIsCorrect() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: demoScan, doesUserPreferEnhancedScan: false)
        let vc = ReviewViewController(results: results)
        vc.viewDidLoad()
        assertSnapshot(matching: vc.imageView, as: .image)
    }

    func testImageIsCorrectlyRotated90() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: demoScan, doesUserPreferEnhancedScan: false)
        let vc = ReviewViewController(results: results)
        vc.viewDidLoad()
        vc.rotateImage()
        assertSnapshot(matching: vc.imageView, as: .image)
    }

    func testImageIsCorrectlyRotated180() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: demoScan, doesUserPreferEnhancedScan: false)
        let vc = ReviewViewController(results: results)
        vc.viewDidLoad()

        vc.rotateImage()
        vc.rotateImage()

        assertSnapshot(matching: vc.imageView, as: .image)
    }

    func testImageIsCorrectlyRotated270() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: demoScan, doesUserPreferEnhancedScan: false)
        let vc = ReviewViewController(results: results)
        vc.viewDidLoad()

        vc.rotateImage()
        vc.rotateImage()
        vc.rotateImage()

        assertSnapshot(matching: vc.imageView, as: .image)
    }

    func testImageIsCorrectlyRotated360() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: demoScan, doesUserPreferEnhancedScan: false)
        let vc = ReviewViewController(results: results)
        vc.viewDidLoad()

        vc.rotateImage()
        vc.rotateImage()
        vc.rotateImage()
        vc.rotateImage()

        assertSnapshot(matching: vc.imageView, as: .image)
    }

    func testEnhancedImage() {
        let results = ImageScannerResults(detectedRectangle: demoQuad, originalScan: demoScan, croppedScan: demoScan, enhancedScan: enhancedDemoScan, doesUserPreferEnhancedScan: false)
        let viewController = ReviewViewController(results: results)
        viewController.viewDidLoad()

        viewController.toggleEnhancedImage()
        assertSnapshot(matching: viewController.imageView, as: .image)
    }
}
