//
//  AVCaptureVideoOrientationTests.swift
//  WeScanTests
//
//  Created by James Campbell on 8/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import AVFoundation
import XCTest

@testable import WeScan

final class AVCaptureVideoOrientationTests: XCTestCase {

  func testPortaitsMapToPortrait() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .portrait), .portrait)
  }

  func testPortaitsUpsideDownMapToPortraitUpsideDown() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .portraitUpsideDown), .portraitUpsideDown)
  }

  func testLandscapeLeftMapToLandscapeLeft() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .landscapeLeft), .landscapeLeft)
  }

  func testLandscapeRightMapToLandscapeRight() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .landscapeRight), .landscapeRight)
  }

  func testFaceUpMapToPortrait() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .faceUp), .portrait)
  }

  func testFaceDownMapToPortraitUpsideDown() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .faceDown), .portraitUpsideDown)
  }

  func testDefaultToPortrait() {
    XCTAssertEqual(AVCaptureVideoOrientation(deviceOrientation: .unknown), .portrait)
  }

}
