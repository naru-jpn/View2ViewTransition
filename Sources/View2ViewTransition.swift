//
//  View2ViewTransition.swift
//  View2ViewTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

/// Protocol for Presenting View Controller
@objc public protocol View2ViewTransitionPresenting {
    
    /// Return initial transition view frame in window.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func initialFrame(userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    /// Return initial transition view.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func initialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    /// Prepare initial transition view (optional).
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func prepereInitialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresenting {
    func prepereInitialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void { }
}

/// Protocol for Presented View Controller
@objc public protocol View2ViewTransitionPresented {
    
    /// Return destination transition view frame in window.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func destinationFrame(userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect
    
    /// Return destination transition view.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func destinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView
    
    /// Prepare destination transition view (optional).
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func prepareDestinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresented {
    func prepereInitialView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> Void { }
}
