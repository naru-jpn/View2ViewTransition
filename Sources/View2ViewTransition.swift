//
//  View2ViewTransition.swift
//  View2ViewTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

@objc public protocol View2ViewTransitionPresenting {
    
    func initialFrame(userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    func initialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    func prepereInitialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}

@objc public protocol View2ViewTransitionPresented {
    
    func destinationFrame(userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    func destinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    func prepareDestinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}
