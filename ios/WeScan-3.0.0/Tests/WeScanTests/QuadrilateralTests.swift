//
//  QuadrilateralTests.swift
//  WeScanTests
//
//  Created by Boris Emorine on 2/14/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//
//  swiftlint:disable function_body_length

@testable import WeScan
import XCTest

final class QuadrilateralTests: XCTestCase {

    func testEquatable() {
        let topLeft = CGPoint(x: 0.0, y: 100.0)
        let topRight = CGPoint(x: 100.0, y: 100.0)
        let bottomRight = CGPoint(x: 100.0, y: 0.0)
        let bottomLeft = CGPoint.zero

        let quad1 = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        var quad2 = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertTrue(quad1 == quad2)

        quad2 = Quadrilateral(topLeft: topLeft, topRight: topLeft, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertFalse(quad1 == quad2)
    }

    func testSquale() {
        var topLeft = CGPoint.zero
        var topRight = CGPoint(x: 100.0, y: 0.0)
        var bottomRight = CGPoint(x: 100.0, y: 100.0)
        var bottomLeft = CGPoint(x: 0.0, y: 100.0)

        var quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        var fromImageSize = CGSize(width: 500.0, height: 500.0)
        var toImageSize = CGSize(width: 1000.0, height: 1000.0)

        var scaledQuad = quad.scale(fromImageSize, toImageSize)

        XCTAssert(scaledQuad.topLeft == .zero)
        XCTAssert(scaledQuad.topRight == CGPoint(x: 200.0, y: 0.0))
        XCTAssert(scaledQuad.bottomRight == CGPoint(x: 200.0, y: 200.0))
        XCTAssert(scaledQuad.bottomLeft == CGPoint(x: 0.0, y: 200.0))

        topLeft = CGPoint(x: 50.0, y: 75.0)
        topRight = CGPoint(x: 100.0, y: 25.0)
        bottomRight = CGPoint(x: 75.0, y: 100.0)
        bottomLeft = CGPoint(x: 25.0, y: 200.0)

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        scaledQuad = quad.scale(fromImageSize, toImageSize)

        XCTAssert(scaledQuad.topLeft == CGPoint(x: 100.0, y: 150.0))
        XCTAssert(scaledQuad.topRight == CGPoint(x: 200.0, y: 50.0))
        XCTAssert(scaledQuad.bottomRight == CGPoint(x: 150.0, y: 200.0))
        XCTAssert(scaledQuad.bottomLeft == CGPoint(x: 50.0, y: 400.0))

        fromImageSize = CGSize(width: 500.0, height: 500.0)
        toImageSize = CGSize(width: 250.0, height: 250.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize)

        XCTAssert(scaledQuad.topLeft == CGPoint(x: 25.0, y: 37.5))
        XCTAssert(scaledQuad.topRight == CGPoint(x: 50.0, y: 12.5))
        XCTAssert(scaledQuad.bottomRight == CGPoint(x: 37.5, y: 50.0))
        XCTAssert(scaledQuad.bottomLeft == CGPoint(x: 12.5, y: 100.0))
    }

    func testScaleFixRotation() {
        var topLeft = CGPoint.zero
        var topRight = CGPoint(x: 500.0, y: 0.0)
        var bottomRight = CGPoint(x: 500.0, y: 500.0)
        var bottomLeft = CGPoint(x: 0.0, y: 500.0)

        var quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        var fromImageSize = CGSize(width: 500.0, height: 500.0)
        var toImageSize = CGSize(width: 500.0, height: 500.0)

        var scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 0.0)))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 0.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: .zero))

        topLeft = CGPoint(x: 0.0, y: 500.0)
        topRight = CGPoint(x: 1000.0, y: 500.0)
        bottomRight = CGPoint(x: 1000.0, y: 0.0)
        bottomLeft = .zero

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        fromImageSize = CGSize(width: 1000.0, height: 500.0)
        toImageSize = CGSize(width: 500.0, height: 1000.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: .zero))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 0.0, y: 1000.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 1000.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 0.0)))

        topLeft = CGPoint(x: 0.0, y: 500.0)
        topRight = CGPoint(x: 1000.0, y: 500.0)
        bottomRight = CGPoint(x: 1000.0, y: 0.0)
        bottomLeft = .zero

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        fromImageSize = CGSize(width: 1000.0, height: 500.0)
        toImageSize = CGSize(width: 250.0, height: 500.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: .zero))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 0.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 250.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 250.0, y: 0.0)))

        topLeft = CGPoint(x: 250.0, y: 500.0)
        topRight = CGPoint(x: 500.0, y: 500.0)
        bottomRight = CGPoint(x: 500.0, y: 250.0)
        bottomLeft = CGPoint(x: 250.0, y: 250.0)

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        fromImageSize = CGSize(width: 750.0, height: 750.0)
        toImageSize = CGSize(width: 750.0, height: 750.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 250.0, y: 250.0)))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 250.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 250.0)))

        topLeft = CGPoint(x: 250.0, y: 500.0)
        topRight = CGPoint(x: 750.0, y: 500.0)
        bottomRight = CGPoint(x: 750.0, y: 250.0)
        bottomLeft = CGPoint(x: 250.0, y: 250.0)

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        fromImageSize = CGSize(width: 1000.0, height: 750.0)
        toImageSize = CGSize(width: 1500.0, height: 2000.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 500.0)))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 500.0, y: 1500.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 1000.0, y: 1500.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 1000.0, y: 500.0)))

        topLeft = CGPoint(x: 100.0, y: 400.0)
        topRight = CGPoint(x: 200.0, y: 400.0)
        bottomRight = CGPoint(x: 200.0, y: 300.0)
        bottomLeft = CGPoint(x: 100.0, y: 300.0)

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        fromImageSize = CGSize(width: 1000.0, height: 500.0)
        toImageSize = CGSize(width: 1000.0, height: 2000.0)

        scaledQuad = quad.scale(fromImageSize, toImageSize, withRotationAngle: CGFloat.pi / 2.0)

        XCTAssertTrue(scaledQuad.topLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 200.0, y: 200.0)))
        XCTAssertTrue(scaledQuad.topRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 200.0, y: 400.0)))
        XCTAssertTrue(scaledQuad.bottomRight.isWithin(delta: 0.01, ofPoint: CGPoint(x: 400.0, y: 400.0)))
        XCTAssertTrue(scaledQuad.bottomLeft.isWithin(delta: 0.01, ofPoint: CGPoint(x: 400.0, y: 200.0)))
    }

    func testReorganize() {
        var topLeft = CGPoint.zero
        var topRight = CGPoint(x: 100.0, y: 0.0)
        var bottomRight = CGPoint(x: 100.0, y: 100.0)
        var bottomLeft = CGPoint(x: 0.0, y: 100.0)

        var quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        quad.reorganize()
        var expectedQuad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertTrue(quad == expectedQuad)

        quad = Quadrilateral(topLeft: bottomRight, topRight: bottomLeft, bottomRight: topLeft, bottomLeft: topRight)
        quad.reorganize()
        expectedQuad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertTrue(quad == expectedQuad)

        topLeft = CGPoint(x: 0.0, y: 50.0)
        topRight = CGPoint(x: 70.0, y: 00.0)
        bottomRight = CGPoint(x: 100.0, y: 70.0)
        bottomLeft = CGPoint(x: 20.0, y: 100.0)

        quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        quad.reorganize()
        expectedQuad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertTrue(quad == expectedQuad)

        quad = Quadrilateral(topLeft: topRight, topRight: topLeft, bottomRight: bottomLeft, bottomLeft: bottomRight)
        quad.reorganize()
        expectedQuad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)

        XCTAssertTrue(quad == expectedQuad)
    }

}
