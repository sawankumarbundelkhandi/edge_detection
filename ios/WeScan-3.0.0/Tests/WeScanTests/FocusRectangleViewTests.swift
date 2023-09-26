//
//  FocusRectangleViewTests.swift
//  WeScanTests
//
//  Created by Julian Schiavo on 24/11/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class FocusRectangleViewTests: XCTestCase {

    func testFocusRectangleIsRemovedCorrectly() {
        let hostView = UIView()
        let session = CaptureSession.current

        let focusRectangle = FocusRectangleView(touchPoint: CGPoint(x: 1, y: 1))
        hostView.addSubview(focusRectangle)
        session.removeFocusRectangleIfNeeded(focusRectangle, animated: false)

        XCTAssertTrue(focusRectangle.superview == nil)
    }

}
