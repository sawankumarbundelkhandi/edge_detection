//
//  CGSizeTests.swift
//  WeScanTests
//
//  Created by Julian Schiavo on 18/2/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class CGSizeTests: XCTestCase {

    func testScaleFactorIsWithinMax() {
        let size = CGSize(width: 5000, height: 1000)
        let scaleFactor = size.scaleFactor(forMaxWidth: 1000, maxHeight: 5000)

        let updatedSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        XCTAssert(updatedSize.width <= 1000)
        XCTAssert(updatedSize.width <= 5000)
    }

    func testScaleFactorCorrectWhenBelowMax() {
        let size = CGSize(width: 10, height: 10)
        let scaleFactor = size.scaleFactor(forMaxWidth: 1000, maxHeight: 5000)

        XCTAssertEqual(scaleFactor, 1)
    }
}
