//
//  VisionRectangleDetectorTests.swift
//  WeScanTests
//
//  Created by James Campbell on 8/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import SnapshotTesting
@testable import WeScan
import XCTest

final class VisionRectangleDetectorTests: XCTestCase {

    private var containerLayer: CALayer!
    private var image: UIImage!

    override func setUp() {
        super.setUp()

        // Setting up containerLayer and creating the image to be tested on both tests in this class.
        containerLayer = CALayer()
        let targetSize = CGSize(width: 150, height: 150)

        containerLayer.backgroundColor = UIColor.white.cgColor
        containerLayer.frame = CGRect(origin: .zero, size: targetSize)
        containerLayer.masksToBounds = true

        let targetLayer = CALayer()
        targetLayer.backgroundColor = UIColor.black.cgColor
        targetLayer.frame = containerLayer.frame.insetBy(dx: 5, dy: 5)

        containerLayer.addSublayer(targetLayer)

        UIGraphicsBeginImageContextWithOptions(targetSize, true, 0.0)

        containerLayer.render(in: UIGraphicsGetCurrentContext()!)

        self.image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

    }

    override func tearDown() {
        super.tearDown()
        containerLayer = nil
        image = nil
    }

    func testCorrectlyDetectsAndReturnsQuadilateral() {

        let ciImage = CIImage(cgImage: image.cgImage!)
        let expectation = XCTestExpectation(description: "Detect rectangle on CIImage")

        VisionRectangleDetector.rectangle(forImage: ciImage) { quad in

            DispatchQueue.main.async {

                let resultView = UIView(frame: self.containerLayer.frame)
                resultView.layer.addSublayer(self.containerLayer)

                let quadView = QuadrilateralView(frame: resultView.bounds)
                quadView.drawQuadrilateral(quad: quad!, animated: false)
                quadView.backgroundColor = UIColor.red
                resultView.addSubview(quadView)

                assertSnapshot(matching: resultView, as: .image)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testCorrectlyDetectsAndReturnsQuadilateralPixelBuffer() {

        let expectation = XCTestExpectation(description: "Detect rectangle on CVPixelBuffer")
        if let pixelBuffer = image.pixelBuffer() {
            VisionRectangleDetector.rectangle(forPixelBuffer: pixelBuffer) { quad in

                DispatchQueue.main.async {

                    let resultView = UIView(frame: self.containerLayer.frame)
                    resultView.layer.addSublayer(self.containerLayer)

                    let quadView = QuadrilateralView(frame: resultView.bounds)
                    quadView.drawQuadrilateral(quad: quad!, animated: false)
                    quadView.backgroundColor = UIColor.red
                    resultView.addSubview(quadView)

                    assertSnapshot(matching: resultView, as: .image)
                    expectation.fulfill()
                }
            }
        } else {
            XCTFail("could not convert image to pixelBuffer")
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
