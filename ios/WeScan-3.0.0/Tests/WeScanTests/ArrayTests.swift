//
//  ArrayTests.swift
//  WeScanTests
//
//  Created by Boris Emorine on 3/6/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

@testable import WeScan
import XCTest

final class ArrayTests: XCTestCase {

    var funnel = RectangleFeaturesFunnel()

    override func setUp() {
        super.setUp()
        funnel = RectangleFeaturesFunnel()
    }

    func testBiggestRectangle() {
        var rects1 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: 10)
        var rects2 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect2, withCount: 10)

        var rectangles: [Quadrilateral] = rects1 + rects2

        var biggestRectangle = rectangles.biggest()
        XCTAssert(biggestRectangle!.isWithin(1.0, ofRectangleFeature: rects1[0]))

        rects1 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect2, withCount: 10)
        rects2 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: 10)

        rectangles = rects1 + rects2

        biggestRectangle = rectangles.biggest()
        XCTAssert(biggestRectangle!.isWithin(1.0, ofRectangleFeature: rects2[0]))

        rects1 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: 10)
        rects2 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect2, withCount: 10)
        let rects3 = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect3, withCount: 10)

        rectangles = rects1 + rects2 + rects3

        biggestRectangle = rectangles.biggest()
        XCTAssert(biggestRectangle!.isWithin(1.0, ofRectangleFeature: rects3[0]))
    }

    func testBiggestRectangleConsistentForSingleElement() {
        let singleRectangle: [Quadrilateral] = ImageFeatureTestHelpers.getRectangleFeatures(from: .rect1, withCount: 1)
        XCTAssertNotNil(singleRectangle.biggest())
    }

}
