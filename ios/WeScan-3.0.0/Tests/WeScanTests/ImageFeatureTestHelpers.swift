//
//  ImageFeatureTestHelpers.swift
//  WeScanTests
//
//  Created by Boris Emorine on 2/24/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import AVFoundation
import UIKit
@testable import WeScan

enum ResourceImage: String {
    case rect1 = "Square.jpg"
    case rect2 = "Rectangle.jpg"
    case rect3 = "BigRectangle.jpg"
}

final class ImageFeatureTestHelpers: NSObject {

    static func getRectangleFeatures(from resourceImage: ResourceImage, withCount count: Int) -> [Quadrilateral] {
        var rectangleFeatures = [Quadrilateral]()

        for _ in 0 ..< count {
            rectangleFeatures.append(ImageFeatureTestHelpers.getRectangleFeature(from: resourceImage))
        }

        return rectangleFeatures
    }

    static func getRectangleFeature(from resourceImage: ResourceImage) -> Quadrilateral {
        let image = UIImage(named: resourceImage.rawValue, in: Bundle.module, compatibleWith: nil)
        let ciImage = CIImage(image: image!)!

        return CIRectangleDetector.rectangle(forImage: ciImage)!
    }

}
