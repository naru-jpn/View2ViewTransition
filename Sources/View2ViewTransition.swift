//
//  View2ViewTransition.swift
//  View2ViewTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

/// Protocol for Presenting View Controller
public protocol View2ViewTransitionPresenting {
    
    /// Return initial transition view frame in window.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func initialFrame(_ userInfo: [String: Any]?, isPresenting: Bool) -> CGRect
    
    /// Return initial transition view.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func initialView(_ userInfo: [String: Any]?, isPresenting: Bool) -> UIView
    
    /// Prepare initial transition view (optional).
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func prepareInitialView(_ userInfo: [String: Any]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresenting {
    func prepareInitialView(_ userInfo: [String: Any]?, isPresenting: Bool) -> Void { }
}

/// Protocol for Presented View Controller
public protocol View2ViewTransitionPresented {
    
    /// Return destination transition view frame in window.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func destinationFrame(_ userInfo: [String: Any]?, isPresenting: Bool) -> CGRect
    
    /// Return destination transition view.
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func destinationView(_ userInfo: [String: Any]?, isPresenting: Bool) -> UIView
    
    /// Prepare destination transition view (optional).
    /// - parameter userInfo: user info
    /// - parameter isPresenting: transition is present or not
    func prepareDestinationView(_ userInfo: [String: Any]?, isPresenting: Bool) -> Void
}

extension View2ViewTransitionPresented {
    func prepareDestinationView(_ userInfo: [String: Any]?, isPresenting: Bool) -> Void { }
}
