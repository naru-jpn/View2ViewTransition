//
//  DismissInteractiveTransition.swift
//  CustomTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

open class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Elements
    
    open var interactionInProgress: Bool = false
    
    open weak var transitionController: TransitionController!
    
    open weak var animationController: DismissAnimationController!
    
    open var initialPanPoint: CGPoint! = CGPoint.zero
    
    fileprivate(set) var transitionContext: UIViewControllerContextTransitioning!
    
    // MARK: Gesture
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    @objc open func handlePanGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer.state == .began {
            
            self.interactionInProgress = true
            panGestureRecognizer.setTranslation(CGPoint.zero, in: panGestureRecognizer.view)
            initialPanPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
            
            switch self.transitionController.type {
            case .presenting:
                self.transitionController.presentedViewController.dismiss(animated: true, completion: nil)
            case .pushing:
                self.transitionController.presentedViewController.navigationController!.popViewController(animated: true)
            }
            
            return
        }
        
        // Get Progress
        let range: Float = Float(UIScreen.main.bounds.size.width)
        let location: CGPoint = panGestureRecognizer.location(in: panGestureRecognizer.view)
        let distance: Float = sqrt(powf(Float(self.initialPanPoint.x - location.x), 2.0) + powf(Float(self.initialPanPoint.y - location.y), 2.0))
        let progress: CGFloat = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Get Transration
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        
        switch panGestureRecognizer.state {
            
        case .changed:
            
            update(progress)
            
            self.animationController.destinationTransitionView.alpha = 1.0
            self.animationController.initialTransitionView.alpha = 0.0
            
            // Affine Transform
            let scale: CGFloat = (1000.0 - CGFloat(distance))/1000.0
            let transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: translation.x/scale, y: translation.y/scale)
            
            animationController.destinationTransitionView.transform = transform
            animationController.initialTransitionView.transform = transform
            
        case .cancelled:
            
            self.interactionInProgress = false
            self.transitionContext.cancelInteractiveTransition()
            
        case .ended:
            
            self.interactionInProgress = false
            
            if progress < 0.5 {
                
                cancel()
                
                let duration: Double = Double(self.duration)*Double(progress)
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIView.AnimationOptions(), animations: {
                    
                    self.animationController.destinationTransitionView.frame = self.animationController.destinationFrame
                    self.animationController.initialTransitionView.frame = self.animationController.destinationFrame
                    
                }, completion: { _ in
                        
                    // Cancel Transition
                    self.animationController.destinationTransitionView.removeFromSuperview()
                    self.animationController.initialTransitionView.removeFromSuperview()
                   
                    self.animationController.destinationView.isHidden = false
                    self.animationController.initialView.isHidden = false
//                    self.transitionController.presentingViewController.view.removeFromSuperview()
                    
                    self.transitionContext.completeTransition(false)
                })
                
            } else {
                
                finish()
                self.transitionController.presentingViewController.view.isUserInteractionEnabled = false
                
                let duration: Double = animationController.transitionDuration
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: UIView.AnimationOptions(), animations: {
                    
                    self.animationController.destinationTransitionView.alpha = 0.0
                    self.animationController.initialTransitionView.alpha = 1.0

                    self.animationController.destinationTransitionView.frame = self.animationController.initialFrame
                    self.animationController.initialTransitionView.frame = self.animationController.initialFrame
                    
                }, completion: { _ in
                    
                    if self.transitionController.type == .pushing {
                            
                        self.animationController.destinationTransitionView.removeFromSuperview()
                        self.animationController.initialTransitionView.removeFromSuperview()
                            
                        self.animationController.initialView.isHidden = false
                        self.animationController.destinationView.isHidden = false
                    }
                    
                    self.transitionController.presentingViewController.view.isUserInteractionEnabled = true
                    self.animationController.initialView.isHidden = false
                    self.transitionContext.completeTransition(true)
                })
            }
            
        default:
            break
        }
    }
}
