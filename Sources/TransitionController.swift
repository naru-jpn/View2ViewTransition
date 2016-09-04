//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class TransitionController: NSObject {

    public var debuging: Bool = false
    
    public var userInfo: [String: AnyObject]? = nil
    
    public lazy var presentAnimationController: PresentAnimationController = {
        let controller: PresentAnimationController = PresentAnimationController()
        controller.transitionController = self
        return controller
    }()
    
    public lazy var dismissAnimationController: DismissAnimationController = {
        let controller: DismissAnimationController = DismissAnimationController()
        controller.transitionController = self
        return controller
    }()
    
    public lazy var dismissInteractiveTransition: DismissInteractiveTransition = {
        let interactiveTransition: DismissInteractiveTransition = DismissInteractiveTransition()
        interactiveTransition.transitionController = self
        interactiveTransition.animationController = self.dismissAnimationController
        return interactiveTransition
    }()
    
    fileprivate(set) var presentingViewController: UIViewController!
    
    fileprivate(set) var presentedViewController: UIViewController!

    /// Type Safe Present for Swift
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) where T: UIViewController, U: UIViewController {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        // Present
        presentingViewController.present(presentedViewController, animated: true, completion: completion)
    }
        
    @available(*, unavailable)
    /// Present for Objective-C
    public func present(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
    
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController

        // Present
        presentingViewController.present(presentedViewController, animated: true, completion: completion)
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissAnimationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}
