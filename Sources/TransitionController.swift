//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public enum TransitionControllerType {
    case presenting
    case pushing
}

public final class TransitionController: NSObject {
    
    public var debuging: Bool = false
    
    public var userInfo: [String: Any]? = nil
    
    private(set) var type: TransitionControllerType = .presenting
    
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
    
    fileprivate(set) weak var presentingViewController: UIViewController!
    
    fileprivate(set) var presentedViewController: UIViewController!

    /// Type Safe Present for Swift
    public func present<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController, completion: (() -> Void)?) where T: UIViewController, U: UIViewController {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .presenting
        
        // Present
        presentingViewController.present(presentedViewController, animated: true, completion: completion)
    }
        
    @available(*, unavailable)
    /// Present for Objective-C
    public func present(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController, completion: (() -> Void)?) {
    
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.type = .presenting
        
        // Present
        self.presentingViewController.present(self.presentedViewController, animated: true, completion: completion)
    }
    
    /// Type Safe Push for Swift
    public func push<T: View2ViewTransitionPresented, U: View2ViewTransitionPresenting>(viewController presentedViewController: T, on presentingViewController: U, attached: UIViewController) where T: UIViewController, U: UIViewController {
        
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
        
        self.type = .pushing
        
        // Push
        navigationController.pushViewController(presentedViewController, animated: true)
    }
    
    @available(*, unavailable)
    /// Push for Objective-C
    public func push(viewController presentedViewController: UIViewController, on presentingViewController: UIViewController, attached: UIViewController) {
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        guard let navigationController = presentingViewController.navigationController else {
            if self.debuging {
                debugPrint("View2ViewTransition << Cannot Find Navigation Controller for Presenting View Controller")
            }
            return
        }
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        
        self.type = .pushing

        // Push
        navigationController.pushViewController(self.presentedViewController, animated: true)
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimationController.prepare()
        return presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissAnimationController.prepare()
        return dismissAnimationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}

extension TransitionController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            presentAnimationController.prepare()
            return presentAnimationController
        case .pop:
            dismissAnimationController.prepare()
            return dismissAnimationController
        default:
            return nil
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController === self.dismissAnimationController && self.dismissInteractiveTransition.interactionInProgress {
            return self.dismissInteractiveTransition
        }
        return nil
    }
}
