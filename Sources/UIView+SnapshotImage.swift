//
//  UIView+SnapshotImage.swift
//  View2ViewTransitionExample
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func snapshotImage() -> UIImage? {
        let size: CGSize = CGSize(width: floor(frame.size.width), height: floor(frame.size.height))
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        let snapshot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshot
    }
}
