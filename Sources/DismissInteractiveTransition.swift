//
//  DismissInteractiveTransition.swift
//  CustomTransition
//
//  Created by naru on 2016/08/29.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public class DismissInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    // MARK: Elements
    
    var interactionInProgress: Bool = false
    
    public weak var transitionController: TransitionController!
    
    public weak var animationController: DismissAnimationController!
    
    var initialPanPoint: CGPoint! = CGPoint.zero
    
    var transitionContext: UIViewControllerContextTransitioning!
    
    // MARK: Gesture
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    public func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer.state == .Began {
            
            self.interactionInProgress = true
            self.initialPanPoint = panGestureRecognizer.locationInView(panGestureRecognizer.view)
            self.transitionController.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        // Get Progress
        let range: Float = Float(UIScreen.mainScreen().bounds.size.width)
        let location: CGPoint = panGestureRecognizer.locationInView(panGestureRecognizer.view)
        let distance: Float = sqrt(powf(Float(self.initialPanPoint.x - location.x), 2.0) + powf(Float(self.initialPanPoint.y - location.y), 2.0))
        let progress: CGFloat = CGFloat(fminf(fmaxf((distance / range), 0.0), 1.0))
        
        // Get Transration
        let translation: CGPoint = panGestureRecognizer.translationInView(panGestureRecognizer.view)
        
        switch panGestureRecognizer.state {
            
        case .Changed:
            
            updateInteractiveTransition(progress)
            
            self.animationController.destinationTransitionView.alpha = 1.0
            self.animationController.initialTransitionView.alpha = 0.0
            
            // Affine Transform
            let scale: CGFloat = (1000.0 - CGFloat(distance))/1000.0
            var transform = CGAffineTransformIdentity
            transform = CGAffineTransformScale(transform, scale, scale)
            transform = CGAffineTransformTranslate(transform, translation.x/scale, translation.y/scale)
            
            self.animationController.destinationTransitionView.transform = transform
            self.animationController.initialTransitionView.transform = transform
            
        case .Cancelled:
            
            self.interactionInProgress = false
            self.transitionContext.cancelInteractiveTransition()
            
        case .Ended:
            
            self.interactionInProgress = false
            panGestureRecognizer.setTranslation(CGPoint.zero, inView: panGestureRecognizer.view)
            
            if progress < 0.5 {
                
                cancelInteractiveTransition()
                
                let duration: Double = Double(self.duration)*Double(progress)
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                    
                    self.animationController.destinationTransitionView.frame = self.animationController.destinationFrame
                    self.animationController.initialTransitionView.frame = self.animationController.destinationFrame
                    
                }, completion: { _ in
                        
                    // Cancel Transition
                    self.animationController.destinationTransitionView.removeFromSuperview()
                    self.animationController.initialTransitionView.removeFromSuperview()
                        
                    self.animationController.destinationView.hidden = false
                    self.animationController.initialView.hidden = false
                    self.transitionController.presentingViewController.view.removeFromSuperview()
                        
                    self.transitionContext.completeTransition(false)
                })
                
            } else {
                
                finishInteractiveTransition()
                self.transitionController.presentingViewController.view.userInteractionEnabled = false
                
                let duration: Double = animationController.transitionDuration
                UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
                    
                    self.animationController.destinationTransitionView.alpha = 0.0
                    self.animationController.initialTransitionView.alpha = 1.0

                    self.animationController.destinationTransitionView.frame = self.animationController.initialFrame
                    self.animationController.initialTransitionView.frame = self.animationController.initialFrame
                    
                }, completion: { _ in
                    
                    self.transitionController.presentingViewController.view.userInteractionEnabled = true
                    self.animationController.initialView.hidden = false
                    self.transitionContext.completeTransition(true)
                })
            }
            
        default:
            break
        }
    }
}
