//
//  UIImage+SFSymbol.swift
//  WeScan
//
//  Created by André Schmidt on 19/06/2020.
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import UIKit

extension UIImage {

    /// Creates an image object containing a system symbol image appropriate for the specified traits if supported (iOS13 and above).
    /// Otherwise an image object using the named image asset that is compatible with the specified trait collection will be created.
    convenience init?(
        systemName: String,
        named: String,
        in bundle: Bundle? = nil,
        compatibleWith traitCollection: UITraitCollection? = nil
    ) {
        if #available(iOS 13.0, *) {
            self.init(systemName: systemName, compatibleWith: traitCollection)
        } else {
            self.init(named: named, in: bundle, compatibleWith: traitCollection)
        }
    }
}
