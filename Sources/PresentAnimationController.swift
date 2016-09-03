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
    
    public var transitionDuration: NSTimeInterval = 0.5
    
    // MARK: Transition

    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextFromViewControllerKey
        let fromController = transitionContext.viewControllerForKey(from)

        guard let fromViewController = fromController as? View2ViewTransitionPresenting where fromViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        let to: String = UITransitionContextToViewControllerKey
        guard let toViewController = transitionContext.viewControllerForKey(to) as? View2ViewTransitionPresented where toViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller (\(transitionContext.viewControllerForKey(to)))")
            }
            return
        }
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        if self.transitionController.debuging {
            debugPrint("View2ViewTransition << Will Present")
            debugPrint(" Presenting view controller: \(fromViewController)")
            debugPrint(" Presented view controller: \(toViewController)")
        }

        fromViewController.prepareInitialView(self.transitionController.userInfo, isPresenting: true)
        let initialView: UIView = fromViewController.initialView(self.transitionController.userInfo, isPresenting: true)
        let initialFrame: CGRect = fromViewController.initialFrame(self.transitionController.userInfo, isPresenting: true)
        
        toViewController.prepareDestinationView(self.transitionController.userInfo, isPresenting: true)
        let destinationView: UIView = toViewController.destinationView(self.transitionController.userInfo, isPresenting: true)
        let destinationFrame: CGRect = toViewController.destinationFrame(self.transitionController.userInfo, isPresenting: true)
        
        let initialTransitionView: UIImageView = UIImageView(image: initialView.snapshotImage())
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .ScaleAspectFill
        
        let destinationTransitionView: UIImageView = UIImageView(image: destinationView.snapshotImage())
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .ScaleAspectFill
        
        // Hide Transisioning Views
        initialView.hidden = true
        destinationView.hidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        toViewControllerView.alpha = CGFloat.min
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView.frame = initialFrame
        containerView.addSubview(initialTransitionView)
        
        destinationTransitionView.frame = initialFrame
        containerView.addSubview(destinationTransitionView)
        destinationTransitionView.alpha = 0.0
        
        // Animation
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        let options: UIViewAnimationOptions = [.CurveEaseInOut, .AllowUserInteraction]
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: options, animations: {
            
            initialTransitionView.frame = destinationFrame
            initialTransitionView.alpha = 0.0
            destinationTransitionView.frame = destinationFrame
            destinationTransitionView.alpha = 1.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            initialTransitionView.removeFromSuperview()
            destinationTransitionView.removeFromSuperview()
                
            initialView.hidden = false
            destinationView.hidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
