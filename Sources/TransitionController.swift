//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class TransitionController: NSObject {

    static let destinationIndexPath = "destinationIndexPath"
    static let initialIndexPath = "initialIndexPath"
    
    public var userInfo: [String: AnyObject]? = nil
    public var presentTransitionDuration: NSTimeInterval = 0.5
    public var dismissTransitionDuration: NSTimeInterval = 0.3
    
    public var debuging: Bool = false

    public lazy var presentAnimationController: PresentAnimationController = {
        let controller: PresentAnimationController = PresentAnimationController()
        controller.transitionController = self
        controller.transitionDuration = self.presentTransitionDuration
        return controller
    }()
    
    public lazy var dismissAnimationController: DismissAnimationController = {
        let controller: DismissAnimationController = DismissAnimationController()
        controller.transitionController = self
        controller.transitionDuration = self.dismissTransitionDuration
        return controller
    }()
    
    public lazy var dismissInteractiveTransition: DismissInteractiveTransition = {
        let interactiveTransition: DismissInteractiveTransition = DismissInteractiveTransition()
        interactiveTransition.transitionController = self
        interactiveTransition.animationController = self.dismissAnimationController
        return interactiveTransition
    }()
    
    private(set) var presentingViewController: UIViewController!
    
    private(set) var presentedViewController: UIViewController!

    /// Type Safe Present for Swift
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting where T: UIViewController, U: UIViewController>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }

    /// Type Safe Present for Swift
    public func push<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting where T: UIViewController, U: UIViewController>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) {
                
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        // Present
        presentingViewController.navigationController?.pushViewController(presentedViewController, animated: true)
    }
    
    @available(*, unavailable)
    /// Present for Objective-C
    public func present(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
    
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController

        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }
    
    @available(*, unavailable)
    /// Present for Objective-C
    public func push(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        // Present
        presentingViewController.navigationController?.pushViewController(presentedViewController, animated: true)
    }
    
    public func registerNavigationController(navigationController: UINavigationController?) {
        guard let navController = navigationController else { return }
        
        navController.delegate = self
    }
    
    public func unregisterNavigationController(navigationController: UINavigationController?) {
        guard let navController = navigationController else { return }
        
        navController.delegate = nil
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

extension TransitionController: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC == presentingViewController {
            return self.presentAnimationController
        } else {
            return self.dismissAnimationController
        }
    }
    
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}
