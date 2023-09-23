//
//  CaptureSessionTests.swift
//  WeScanTests
//
//  Created by James Campbell on 8/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import AVFoundation
@testable import WeScan
import XCTest

final class CaptureSessionTests: XCTestCase {

    private let session = CaptureSession.current

    func testAutoScanEnabledByDefault() {
        XCTAssertTrue(session.isAutoScanEnabled)
    }

    func testEditOrientationUpByDefault() {
        XCTAssertEqual(session.editImageOrientation, CGImagePropertyOrientation.up)
    }

    func testCaptureDeviceIsAvailable() {
        session.device = MockCaptureDevice()
        XCTAssertNotNil(session.device)
    }

    func testCanToggleFlash() {
        session.device = MockCaptureDevice()

        let state = session.toggleFlash()
        XCTAssertEqual(state, CaptureSession.FlashState.on)
    }

    func testCanSetFocusPoint() {
        session.device = MockCaptureDevice()
        XCTAssertNoThrow(try session.setFocusPointToTapPoint(.zero))
    }

    func testCanResetFocusToAuto() {
        session.device = MockCaptureDevice()
        XCTAssertNoThrow(try session.resetFocusToAuto())
        XCTAssertEqual(session.device?.focusMode, AVCaptureDevice.FocusMode.continuousAutoFocus)
    }

}
