//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public enum TransitionControllerType {
    case Presenting
    case Pushing
}

public final class TransitionController: NSObject {
    
    public var debuging: Bool = false
    
    public var userInfo: [String: AnyObject]? = nil
    
    private(set) var type: TransitionControllerType = .Presenting
    
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
    
    private(set) var presentingViewController: UIViewController!
    
    private(set) var presentedViewController: UIViewController!

    /// Type Safe Present for Swift
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting where T: UIViewController, U: UIViewController>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .Presenting
        
        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }
        
    @available(*, unavailable)
    /// Present for Objective-C
    public func present(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
    
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController

        self.type = .Presenting
        
        // Present
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: completion)
    }
    
    /// Type Safe Push for Swift
    public func push<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting where T: UIViewController, U: UIViewController>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController) {
        
        guard let navigationController = presentingViewController.navigationController else {
            if self.debuging {
                debugPrint("View2ViewTransition << Cannot Find Navigation Controller for Presenting View Controller")
            }
            return
        }
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .Pushing
        
        // Push
        navigationController.pushViewController(presentedViewController, animated: true)
    }
    
    @available(*, unavailable)
    /// Push for Objective-C
    public func push(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController) {
        
        guard let navigationController = presentingViewController.navigationController else {
            if self.debuging {
                debugPrint("View2ViewTransition << Cannot Find Navigation Controller for Presenting View Controller")
            }
            return
        }
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .Pushing
        
        // Push
        navigationController.pushViewController(presentedViewController, animated: true)
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
        switch operation {
        case .Push:
            return self.presentAnimationController
        case .Pop:
            return self.dismissAnimationController
        default:
            return nil
        }
    }
    
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController === self.dismissAnimationController && self.dismissInteractiveTransition.interactionInProgress {
            return self.dismissInteractiveTransition
        }
        return nil
    }
}
