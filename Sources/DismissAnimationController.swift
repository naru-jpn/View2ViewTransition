//
//  DismissAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public override init() {
        super.init()
        
        // Create Snapshot from Destination View
        destinationTransitionView = UIImageView(image: nil)
        destinationTransitionView.clipsToBounds = true
        destinationTransitionView.contentMode = .scaleAspectFill
        
        initialTransitionView = UIImageView(image: nil)
        initialTransitionView.clipsToBounds = true
        initialTransitionView.contentMode = .scaleAspectFill
    }
    
    // MARK: - Elements

    public weak var transitionController: TransitionController!
    
    public var transitionDuration: TimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIView.AnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    public var usingSpringWithDampingCancelling: CGFloat = 1.0
    
    public var initialSpringVelocityCancelling: CGFloat = 0.0
    
    public var animationOptionsCancelling: UIView.AnimationOptions = [.curveEaseInOut, .allowUserInteraction]

    fileprivate(set) var initialView: UIView!
    
    fileprivate(set) var destinationView: UIView!
    
    fileprivate(set) var initialFrame: CGRect!
    
    fileprivate(set) var destinationFrame: CGRect!
    
    fileprivate(set) var initialTransitionView: UIImageView!
    
    fileprivate(set) var destinationTransitionView: UIImageView!

    var initialSnapshotImage: UIImage?
    
    var destinationSnapshotImage: UIImage?
    
    // MARK: - Prepare
    
    func prepare() {
        
        guard let presentingViewController: View2ViewTransitionPresenting = transitionController.presentingViewController as? View2ViewTransitionPresenting else {
            return
        }
        guard let presentedViewController: View2ViewTransitionPresented = transitionController.presentedViewController as? View2ViewTransitionPresented else {
            return
        }
        
        presentingViewController.prepareInitialView(transitionController.userInfo, isPresenting: false)
        let initialView: UIView = presentingViewController.initialView(transitionController.userInfo, isPresenting: false)
        initialSnapshotImage = initialView.snapshotImage()
        
        presentedViewController.prepareDestinationView(transitionController.userInfo, isPresenting: false)
        let destinationView: UIView = presentedViewController.destinationView(transitionController.userInfo, isPresenting: false)
        destinationSnapshotImage = destinationView.snapshotImage()
    }
    
    // MARK: - Transition
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? View2ViewTransitionPresented , fromViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as Any))")
            }
            return
        }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? View2ViewTransitionPresenting , toViewController is UIViewController else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as Any))")
            }
            return
        }
        
        if self.transitionController.debuging {
            debugPrint("View2ViewTransition << Will Dismiss")
            debugPrint(" Presented view controller: \(fromViewController)")
            debugPrint(" Presenting view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView
        
        fromViewController.prepareDestinationView(self.transitionController.userInfo, isPresenting: false)
        destinationView = fromViewController.destinationView(self.transitionController.userInfo, isPresenting: false)
        destinationFrame = fromViewController.destinationFrame(self.transitionController.userInfo, isPresenting: false)
        
        toViewController.prepareInitialView(self.transitionController.userInfo, isPresenting: false)
        initialView = toViewController.initialView(self.transitionController.userInfo, isPresenting: false)
        initialFrame = toViewController.initialFrame(self.transitionController.userInfo, isPresenting: false)
                
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add To,FromViewController's View
        let toViewControllerView: UIView = (toViewController as! UIViewController).view
        let fromViewControllerView: UIView = (fromViewController as! UIViewController).view
        containerView.addSubview(fromViewControllerView)
        
        // This condition is to prevent getting white screen at dismissing when multiple view controller are presented.
        let isNeedToControlToViewController: Bool = toViewControllerView.superview == nil
        if isNeedToControlToViewController {
            containerView.addSubview(toViewControllerView)
            containerView.sendSubviewToBack(toViewControllerView)
        }
        
        // Add Snapshot
        destinationTransitionView.transform = .identity
        destinationTransitionView.image = destinationSnapshotImage
        destinationTransitionView.frame = destinationFrame
        containerView.addSubview(destinationTransitionView)
        
        initialTransitionView.transform = .identity
        initialTransitionView.image = initialSnapshotImage
        initialTransitionView.frame = destinationFrame
        containerView.addSubview(initialTransitionView)
        initialTransitionView.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        
        if transitionContext.isInteractive {
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDampingCancelling, initialSpringVelocity: self.initialSpringVelocityCancelling, options: self.animationOptionsCancelling, animations: {
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
            }, completion: nil)
            
        } else {
        
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
                
                self.destinationTransitionView.frame = self.initialFrame
                self.initialTransitionView.frame = self.initialFrame
                self.initialTransitionView.alpha = 1.0
                fromViewControllerView.alpha = CGFloat.leastNormalMagnitude
                
            }, completion: { _ in
                    
                self.destinationTransitionView.removeFromSuperview()
                self.initialTransitionView.removeFromSuperview()
                
                if isNeedToControlToViewController && self.transitionController.type == .presenting {
                    toViewControllerView.removeFromSuperview()
                }
                
                self.initialView.isHidden = false
                self.destinationView.isHidden = false
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
