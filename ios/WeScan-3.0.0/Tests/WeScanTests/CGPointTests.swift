//
//  CGPointTests.swift
//  WeScanTests
//
//  Created by Boris Emorine on 2/19/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class CGPointTests: XCTestCase {

    func testSurroundingRect() {
        var point = CGPoint.zero
        var rect = point.surroundingSquare(withSize: 10.0)
        var expectedRect = CGRect(x: -5.0, y: -5.0, width: 10.0, height: 10.0)
        XCTAssert(rect == expectedRect)

        point = CGPoint(x: 50.0, y: 50.0)
        rect = point.surroundingSquare(withSize: 20.0)
        expectedRect = CGRect(x: 40.0, y: 40.0, width: 20.0, height: 20.0)
        XCTAssert(rect == expectedRect)
    }

    func testIsWithinDelta() {
        let point1 = CGPoint.zero
        var point2 = CGPoint.zero

        XCTAssert(point1.isWithin(delta: 10.0, ofPoint: point2) == true)
        XCTAssert(point1.isWithin(delta: 0.0, ofPoint: point2) == true)

        point2 = CGPoint(x: 1.0, y: 1.0)

        XCTAssert(point1.isWithin(delta: 1.1, ofPoint: point2) == true)
        XCTAssert(point1.isWithin(delta: 0.9, ofPoint: point2) == false)
    }

    func testDistanceTo() {
        var point1 = CGPoint.zero
        var point2 = CGPoint(x: 10.0, y: 10.0)

        var distance = point1.distanceTo(point: point2)
        XCTAssertTrue(distance == 14.142135623730951)

        point1 = CGPoint(x: -1, y: 3)
        point2 = CGPoint(x: 3, y: -4)
        distance = point1.distanceTo(point: point2)
        XCTAssertTrue(distance == 8.06225774829855)
    }

}
