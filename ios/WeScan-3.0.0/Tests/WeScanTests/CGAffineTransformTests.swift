//
//  CGAffineTransformTests.swift
//  WeScanTests
//
//  Created by James Campbell on 8/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class CGAffineTransformTests: XCTestCase {

  func testScalesUpCorrectly() {

    let fromSize = CGSize(width: 1, height: 1)
    let toSize = CGSize(width: 2, height: 2)

    let scale = CGAffineTransform.scaleTransform(forSize: fromSize, aspectFillInSize: toSize)

    XCTAssertEqual(scale.a, 2)
    XCTAssertEqual(scale.d, 2)
  }

  func testScalesDownCorrectly() {

    let fromSize = CGSize(width: 2, height: 2)
    let toSize = CGSize(width: 1, height: 1)

    let scale = CGAffineTransform.scaleTransform(forSize: fromSize, aspectFillInSize: toSize)

    XCTAssertEqual(scale.a, 0.5)
    XCTAssertEqual(scale.d, 0.5)
  }

  func testTranslatesCorrectly() {

    let fromRect = CGRect(x: 0, y: 0, width: 10, height: 10)
    let toRect = CGRect(x: 5, y: 5, width: 10, height: 10)

    let translate = CGAffineTransform.translateTransform(fromCenterOfRect: fromRect, toCenterOfRect: toRect)

    XCTAssertEqual(translate.a, 1.0)
    XCTAssertEqual(translate.d, 1.0)
    XCTAssertEqual(translate.tx, 5.0)
    XCTAssertEqual(translate.ty, 5.0)
  }

}
