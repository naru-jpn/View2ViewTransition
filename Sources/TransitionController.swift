//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class TransitionController: NSObject {

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
    
    var presentingViewController: UIViewController!
    
    var presentedViewController: UIViewController!

    /// Type Safe Present for Swift
    func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting where T: UIViewController, U: UIViewController>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }
        
    @available(*, unavailable)
    /// Present for Objective-C
    func present(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
    
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.presentAnimationController
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissAnimationController
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}
