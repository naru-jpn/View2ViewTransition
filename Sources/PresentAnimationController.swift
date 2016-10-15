//
//  PresentAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Elements
    
    public weak var transitionController: TransitionController!
    
    public var transitionDuration: TimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    // MARK: Transition

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View

        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresenting , fromViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from))))")
            }
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresented , toViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)))")
            }
            return
        }
        
        if self.transitionController.debuging {
            debugPrint("View2ViewTransition << Will Present")
            debugPrint(" Presenting view controller: \(fromViewController)")
            debugPrint(" Presented view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView

        fromViewController.prepareInitialView(self.transitionController.userInfo, isPresenting: true)
        let initialView: UIView = fromViewController.initialView(self.transitionController.userInfo, isPresenting: true)
        let initialFrame: CGRect = fromViewController.initialFrame(self.transitionController.userInfo, isPresenting: true)
        
        toViewController.prepareDestinationView(self.transitionController.userInfo, isPresenting: true)
        let destinationView: UIView = toViewController.destinationView(self.transitionController.userInfo, isPresenting: true)
        let destinationFrame: CGRect = toViewController.destinationFrame(self.transitionController.userInfo, isPresenting: true)
        
        let initialTransitionView: UIImageView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .scaleAspectFill
        
        let destinationTransitionView: UIImageView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .scaleAspectFill
        
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
            
            initialTransitionView.frame = destinationFrame
            initialTransitionView.alpha = 0.0
            destinationTransitionView.frame = destinationFrame
            destinationTransitionView.alpha = 1.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            initialTransitionView.removeFromSuperview()
            destinationTransitionView.removeFromSuperview()
                
            initialView.isHidden = false
            destinationView.isHidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
