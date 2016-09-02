//
//  DismissAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Elements

    public weak var transitionController: TransitionController!
    
    public var transitionDuration: NSTimeInterval = 0.5
    
    private(set) var initialView: UIView!
    
    private(set) var destinationView: UIView!
    
    private(set) var initialFrame: CGRect!
    
    private(set) var destinationFrame: CGRect!
    
    private(set) var initialTransitionView: UIView!
    
    private(set) var destinationTransitionView: UIView!

    // MARK: Transition
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View
        let from: String = UITransitionContextFromViewControllerKey
        guard let fromViewController = transitionContext.viewControllerForKey(from) as? View2ViewTransitionPresented where fromViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        let to: String = UITransitionContextToViewControllerKey
        guard let toViewController = transitionContext.viewControllerForKey(to) as? View2ViewTransitionPresenting where toViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewControllerForKey(from)))")
            }
            return
        }
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        fromViewController.prepareDestinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationView = fromViewController.destinationView(self.transitionController.userInfo, isPresenting: false)
        self.destinationFrame = fromViewController.destinationFrame(self.transitionController.userInfo, isPresenting: false)
        
        toViewController.prepereInitialView(self.transitionController.userInfo, isPresenting: false)
        self.initialView = toViewController.initialView(self.transitionController.userInfo, isPresenting: false)
        self.initialFrame = toViewController.initialFrame(self.transitionController.userInfo, isPresenting: false)
        
        // Create Snapshot from Destination View
        self.destinationTransitionView = UIImageView(image: destinationView.snapshotImage())
        self.destinationTransitionView.clipsToBounds = true
        self.destinationTransitionView.contentMode = .ScaleAspectFill
        
        self.initialTransitionView = UIImageView(image: initialView.snapshotImage())
        self.initialTransitionView.clipsToBounds = true
        self.initialTransitionView.contentMode = .ScaleAspectFill
                
        // Hide Transisioning Views
        initialView.hidden = true
        destinationView.hidden = true
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        containerView.addSubview(toViewControllerView)
        let fromViewControllerView: UIView = (fromViewController as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // Add Snapshot
        self.destinationTransitionView.frame = destinationFrame
        containerView.addSubview(self.destinationTransitionView)
        
        self.initialTransitionView.frame = destinationFrame
        containerView.addSubview(self.initialTransitionView)
        self.initialTransitionView.alpha = 0.0
        
        // Animation
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        let options: UIViewAnimationOptions = [.CurveEaseInOut, .AllowUserInteraction]
        
        if transitionContext.isInteractive() {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: options, animations: {
                fromViewControllerView.alpha = CGFloat.min
            }, completion: nil)
            
        } else {
            
            UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: options, animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.min
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                toViewControllerView.removeFromSuperview()
                    
                self.initialView.hidden = false
                self.destinationView.hidden = false
                    
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }
    }
}
