//
//  CGRectTests.swift
//  WeScanTests
//
//  Created by Boris Emorine on 2/26/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class CGRectTests: XCTestCase {

    func testScaleAndCenter() {
        var rect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        rect = rect.scaleAndCenter(withRatio: 0.5)
        var expectedRect = CGRect(x: 25.0, y: 25.0, width: 50.0, height: 50.0)

        XCTAssert(rect == expectedRect)

        rect = CGRect(x: 100.0, y: 100.0, width: 200.0, height: 200.0)
        rect = rect.scaleAndCenter(withRatio: 0.75)
        expectedRect = CGRect(x: 125.0, y: 125.0, width: 150.0, height: 150.0)

        XCTAssert(rect == expectedRect)

        rect = CGRect(x: 100.0, y: 100.0, width: 200.0, height: 200.0)
        rect = rect.scaleAndCenter(withRatio: 2.0)
        expectedRect = CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0)

        XCTAssert(rect == expectedRect)
    }

}
