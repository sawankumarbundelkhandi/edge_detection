//
//  CIImage+Utils.swift
//  WeScan
//
//  Created by Julian Schiavo on 14/11/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import CoreImage
import Foundation
import UIKit

extension CIImage {
    /// Applies an AdaptiveThresholding filter to the image, which enhances the image and makes it completely gray scale
    func applyingAdaptiveThreshold() -> UIImage? {
        guard let colorKernel = CIColorKernel(source:
            """
            kernel vec4 color(__sample pixel, float inputEdgeO, float inputEdge1)
            {
                float luma = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));
                float threshold = smoothstep(inputEdgeO, inputEdge1, luma);
                return vec4(threshold, threshold, threshold, 1.0);
            }
            """
            ) else { return nil }

        let firstInputEdge = 0.25
        let secondInputEdge = 0.75

        let arguments: [Any] = [self, firstInputEdge, secondInputEdge]

        guard let enhancedCIImage = colorKernel.apply(extent: self.extent, arguments: arguments) else { return nil }

        if let cgImage = CIContext(options: nil).createCGImage(enhancedCIImage, from: enhancedCIImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage(ciImage: enhancedCIImage, scale: 1.0, orientation: .up)
        }
    }
}
