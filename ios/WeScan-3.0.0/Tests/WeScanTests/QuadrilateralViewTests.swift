//
//  QuadrilateralViewTests.swift
//  WeScanTests
//
//  Created by Bobo on 6/9/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//
//  swiftlint:disable line_length

@testable import WeScan
import XCTest

final class QuadrilateralViewTests: XCTestCase {

    let vc = UIViewController()

    override func setUp() {
        super.setUp()
        vc.loadView()
    }

    func testNonEditable() {
        let quadView = QuadrilateralView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        quadView.editable = false
        vc.view.addSubview(quadView)

        let topLeftCornerView = quadView.cornerViewForCornerPosition(position: .topLeft)

        XCTAssertTrue(topLeftCornerView.isHidden, "A non editable QuadrilateralView should have hidden corners")
    }

    func testHightlight() {
        let quadView = QuadrilateralView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        quadView.editable = true
        vc.view.addSubview(quadView)

        let quad = Quadrilateral(topLeft: .zero, topRight: CGPoint(x: 200.0, y: 0.0), bottomRight: CGPoint(x: 200.0, y: 200.0), bottomLeft: CGPoint(x: 0.0, y: 220.0))

        quadView.drawQuadrilateral(quad: quad, animated: false)

        let topRightCornerView = quadView.cornerViewForCornerPosition(position: .topRight)

        XCTAssertFalse(topRightCornerView.isHidden, "An editable QuadrilateralView should not have hidden corners")

        let defaultTopLeftCornerViewFrame = topRightCornerView.frame

        quadView.highlightCornerAtPosition(position: .topRight, with: UIImage())

        let highlitedTopLeftCornerViewFrame = topRightCornerView.frame

        XCTAssert(defaultTopLeftCornerViewFrame.width < highlitedTopLeftCornerViewFrame.width, "A highlighted corner view should be bigger than in its default state")
        XCTAssert(defaultTopLeftCornerViewFrame.height < highlitedTopLeftCornerViewFrame.height, "A highlighted corner view should be bigger than in its default state")
        XCTAssertEqual(defaultTopLeftCornerViewFrame.origin.x + defaultTopLeftCornerViewFrame.width / 2.0, highlitedTopLeftCornerViewFrame.origin.x + highlitedTopLeftCornerViewFrame.width / 2.0, "A highlighted corner view should have the same center as in its default state")
        XCTAssertEqual(defaultTopLeftCornerViewFrame.origin.y + defaultTopLeftCornerViewFrame.height / 2.0, highlitedTopLeftCornerViewFrame.origin.y + highlitedTopLeftCornerViewFrame.height / 2.0, "A highlighted corner view should have the same center as in its default state")
        XCTAssertTrue(topRightCornerView.isHighlighted)

        quadView.resetHighlightedCornerViews()

        XCTAssert(defaultTopLeftCornerViewFrame.width == topRightCornerView.frame.width, "After reseting, the corner view frame should be back to its inital value")
        XCTAssert(defaultTopLeftCornerViewFrame.height == topRightCornerView.frame.height, "After reseting, the corner view frame should be back to its inital value")
        XCTAssertEqual(defaultTopLeftCornerViewFrame.origin.x + defaultTopLeftCornerViewFrame.width / 2.0, topRightCornerView.center.x, "After reseting, the corner view center should still not have moved")
        XCTAssertEqual(defaultTopLeftCornerViewFrame.origin.y + defaultTopLeftCornerViewFrame.height / 2.0, topRightCornerView.center.y, "After reseting, the corner view center should still not have moved")
        XCTAssertFalse(topRightCornerView.isHighlighted)
    }

    func testDrawQuad() {
        let quadView = QuadrilateralView(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        quadView.editable = true
        vc.view.addSubview(quadView)

        let quad = Quadrilateral(topLeft: .zero, topRight: CGPoint(x: 200.0, y: 0.0), bottomRight: CGPoint(x: 200.0, y: 200.0), bottomLeft: CGPoint(x: 0.0, y: 220.0))

        quadView.drawQuadrilateral(quad: quad, animated: false)

        let topLeftCornerView = quadView.cornerViewForCornerPosition(position: .topLeft)
        XCTAssertEqual(topLeftCornerView.center, quad.topLeft)

        let topRightCornerView = quadView.cornerViewForCornerPosition(position: .topRight)
        XCTAssertEqual(topRightCornerView.center, quad.topRight)

        let bottomRightCornerView = quadView.cornerViewForCornerPosition(position: .bottomRight)
        XCTAssertEqual(bottomRightCornerView.center, quad.bottomRight)

        let bottomLeftCornerView = quadView.cornerViewForCornerPosition(position: .bottomLeft)
        XCTAssertEqual(bottomLeftCornerView.center, quad.bottomLeft)
    }

}
