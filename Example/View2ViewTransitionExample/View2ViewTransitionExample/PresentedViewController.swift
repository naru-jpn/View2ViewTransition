//
//  PresentedViewController.swift
//  CustomTransition
//
//  Created by naru on 2016/07/27.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.collectionView)
        self.view.backgroundColor = UIColor.whiteColor()
      
        if isModalTransition {
            self.view.addSubview(self.closeButton)
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(onCloseButtonClicked))
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let gestureRecognizers = self.view.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                    panGestureRecognizer.delegate = self
                }
            }
        }
    }
    
    // MARK: Elements
    
    weak var transitionController: TransitionController!
    
    var isModalTransition = true
    
    lazy var collectionView: UICollectionView = {
        let width = self.view.bounds.width
        let height = width / 3 * 4
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .Horizontal
        
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        
        collectionView.registerClass(PresentedCollectionViewCell.self, forCellWithReuseIdentifier: "presented_cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)

        return collectionView
    }()
    
    lazy var closeButton: UIButton = {
        let frame: CGRect = CGRect(x: self.view.bounds.size.width - 60, y: 20.0, width: 60.0, height: 40.0)
        let button: UIButton = UIButton(frame: frame)
        button.setTitle("Close", forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: .Normal)
        button.addTarget(self, action: #selector(onCloseButtonClicked), forControlEvents: .TouchUpInside)
        return button
    }()
    
    // MARK: CollectionView Data Source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: PresentedCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("presented_cell", forIndexPath: indexPath) as! PresentedCollectionViewCell
        cell.contentView.backgroundColor = UIColor.whiteColor()
        
        let number: Int = indexPath.item%4 + 1
        cell.content.image = UIImage(named: "image\(number)")
        
        return cell
    }
    
    // MARK: Actions
    
    func onCloseButtonClicked() {
        
        let indexPath: NSIndexPath = self.collectionView.indexPathsForVisibleItems().first!
        self.transitionController.userInfo = [destinationIndexPath: indexPath, initialIndexPath: indexPath]
        
        if let navController = navigationController {
            navController.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: Gesture Delegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let indexPath: NSIndexPath = self.collectionView.indexPathsForVisibleItems().first!
        self.transitionController.userInfo = [destinationIndexPath: indexPath, initialIndexPath: indexPath]
        
        let panGestureRecognizer: UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        let translate: CGPoint = panGestureRecognizer.translationInView(self.view)
        return Double(abs(translate.y)/abs(translate.x)) > M_PI_4
    }
}

extension PresentedViewController: View2ViewTransitionPresented {
    
    func destinationFrame(userInfo: [String: AnyObject]?, isPresenting: Bool) -> CGRect {
        
        let indexPath: NSIndexPath = userInfo![destinationIndexPath] as! NSIndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PresentedCollectionViewCell
        
        let subFrame = cell.contentView.convertRect(cell.content.frame, toView: cell)
        var frame = subFrame
                
        let attributes: UICollectionViewLayoutAttributes = self.collectionView.layoutAttributesForItemAtIndexPath(indexPath)! 
        let cellFrame = self.collectionView.convertRect(attributes.frame, toView: self.collectionView.superview)

        let margin: CGFloat = 2.0
        
        frame.origin.x = margin
        frame.origin.y += cellFrame.origin.y
        
        return frame
    }
    
    func destinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) -> UIView {
        
        let indexPath: NSIndexPath = userInfo![destinationIndexPath] as! NSIndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItemAtIndexPath(indexPath) as! PresentedCollectionViewCell
        return cell.content
    }
    
    func prepareDestinationView(userInfo: [String: AnyObject]?, isPresenting: Bool) {
        
        if isPresenting {
            
            let indexPath: NSIndexPath = userInfo![destinationIndexPath] as! NSIndexPath
            let contentOfffset: CGPoint = CGPoint(x: self.collectionView.frame.size.width*CGFloat(indexPath.item), y: 0.0)
            self.collectionView.contentOffset = contentOfffset
            
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
}

public class PresentedCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.content)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let margin: CGFloat = 2.0
        let width: CGFloat = (self.bounds.size.width - margin * 2.0)
        let height: CGFloat = (width / 3 * 4)
        
        content.frame = CGRect(x: margin, y: (self.bounds.size.height - height)/2.0, width: width, height: height)
    }
    
    public lazy var content: UIImageView = {
        let view: UIImageView = UIImageView()
        view.backgroundColor = UIColor.grayColor()
        view.clipsToBounds = true
        view.contentMode = .ScaleAspectFill
        return view
    }()
}
