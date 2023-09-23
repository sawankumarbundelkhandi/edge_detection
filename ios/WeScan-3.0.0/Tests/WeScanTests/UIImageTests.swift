//
//  UIImageTests.swift
//  WeScanTests
//
//  Created by James Campbell on 8/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import SnapshotTesting
@testable import WeScan
import XCTest

final class UIImageTests: XCTestCase {

    func testRotateUpFacingImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)
        let orientatedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: .up)

        let view = UIImageView(image: orientatedImage.applyingPortraitOrientation())
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testRotateDownFacingImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)
        let orientatedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: .down)

        let view = UIImageView(image: orientatedImage.applyingPortraitOrientation())
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testRotateLeftFacingImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)
        let orientatedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: .left)

        let view = UIImageView(image: orientatedImage.applyingPortraitOrientation())
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testRotateRightFacingImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)
        let orientatedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: .right)

        let view = UIImageView(image: orientatedImage.applyingPortraitOrientation())
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testRotateDefaultFacingImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)
        let orientatedImage = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: .rightMirrored)

        let view = UIImageView(image: orientatedImage.applyingPortraitOrientation())
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testRotateImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)

        let view = UIImageView(image: image!.rotated(by: Measurement(value: Double.pi * 0.2, unit: .radians), options: []))
        view.sizeToFit()

        assertSnapshot(matching: view, as: .image)
    }

    func testScaledImageSuccessfully() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)!
        XCTAssertNotNil(image.scaledImage(scaleFactor: 0.2))
    }

    func testScaledImageCorrectly() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)!
        XCTAssertEqual(image.size, CGSize(width: 500, height: 500))
        XCTAssertEqual(image.scaledImage(scaleFactor: 0.2)!.size, CGSize(width: 100, height: 100))
    }

    func testPDFDataCreationSuccessful() {
        let image = UIImage(named: ResourceImage.rect2.rawValue, in: Bundle.module, compatibleWith: nil)!
        XCTAssertNotNil(image.pdfData())
    }
}
