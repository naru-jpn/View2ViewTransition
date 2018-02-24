//
//  PresentedViewController.swift
//  CustomTransition
//
//  Created by naru on 2016/07/27.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = titleLabel
        navigationItem.leftBarButtonItem = backItem
        view.backgroundColor = UIColor.white
        
        view.addSubview(self.collectionView)
        view.addSubview(self.closeButton)
    }

    override func viewDidAppear(_ animated: Bool) {
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
    
    lazy var collectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(PresentedCollectionViewCell.self, forCellWithReuseIdentifier: "presented_cell")
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var closeButton: UIButton = {
        let frame: CGRect = CGRect(x: 0.0, y: 20.0, width: 60.0, height: 40.0)
        let button: UIButton = UIButton(frame: frame)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(self.view.tintColor, for: .normal)
        button.addTarget(self, action: #selector(onCloseButtonClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let font: UIFont = UIFont.boldSystemFont(ofSize: 16.0)
        let label: UILabel = UILabel()
        label.font = font
        label.text = "Detail"
        label.sizeToFit()
        return label
    }()
    
    lazy var backItem: UIBarButtonItem = {
        let item: UIBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(onBackItemClicked(sender:)))
        return item
    }()
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.bounds.width
        let height: CGFloat
        if let navigationController: UINavigationController = navigationController {
            if #available(iOS 11.0, *) {
                height = collectionView.bounds.height - navigationController.view.safeAreaInsets.top - navigationController.view.safeAreaInsets.bottom - 44.0
            } else {
                height = collectionView.bounds.height - navigationController.navigationBar.bounds.height
            }
        } else {
            height = collectionView.bounds.height
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }      
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PresentedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "presented_cell", for: indexPath) as! PresentedCollectionViewCell
        cell.contentView.backgroundColor = UIColor.white
        cell.content.image = UIImage(named: "image\(indexPath.item%4 + 1)")
        return cell
    }
    
    // MARK: Actions
    
    @objc func onCloseButtonClicked(sender: AnyObject) {
        let indexPath: NSIndexPath = self.collectionView.indexPathsForVisibleItems.first! as NSIndexPath
        self.transitionController.userInfo = ["destinationIndexPath": indexPath, "initialIndexPath": indexPath]
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onBackItemClicked(sender: AnyObject) {
        
        let indexPath: NSIndexPath = self.collectionView.indexPathsForVisibleItems.first! as NSIndexPath
        self.transitionController.userInfo = ["destinationIndexPath": indexPath, "initialIndexPath": indexPath]
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    // MARK: Gesture Delegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let indexPath: NSIndexPath = self.collectionView.indexPathsForVisibleItems.first! as NSIndexPath
        self.transitionController.userInfo = ["destinationIndexPath": indexPath, "initialIndexPath": indexPath]

        let panGestureRecognizer: UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
        let transate: CGPoint = panGestureRecognizer.translation(in: self.view)
        return Double(abs(transate.y)/abs(transate.x)) > .pi / 4.0
    }
}

extension PresentedViewController: View2ViewTransitionPresented {
    
    func destinationFrame(_ userInfo: [String: Any]?, isPresenting: Bool) -> CGRect {
        let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! PresentedCollectionViewCell
        // FIXME: Get frame on collection view more smart!!
        if let _ = navigationController, #available(iOS 11.0, *) {
            var frame: CGRect = cell.contentView.convert(cell.content.frame, to: view)
            frame.origin.y += 27.0
            return frame
        } else {
            return cell.contentView.convert(cell.content.frame, to: view)
        }
    }

    func destinationView(_ userInfo: [String: Any]?, isPresenting: Bool) -> UIView {
        
        let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
        let cell: PresentedCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! PresentedCollectionViewCell
        return cell.content
    }
    
    func prepareDestinationView(_ userInfo: [String: Any]?, isPresenting: Bool) {
        
        if isPresenting {
            
            let indexPath: IndexPath = userInfo!["destinationIndexPath"] as! IndexPath
            let contentOfffset: CGPoint = CGPoint(x: self.collectionView.frame.size.width*CGFloat(indexPath.item), y: 0.0)
            self.collectionView.contentOffset = contentOfffset
            
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
}

class PresentedCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(content)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var content: UIImageView = {
        let margin: CGFloat = 2.0
        let width: CGFloat = (bounds.size.width - margin*2.0)
        let height: CGFloat = (bounds.size.height - 160.0)
        let frame: CGRect = CGRect(x: margin, y: (bounds.size.height - height)/2.0, width: width, height: height)
        let view: UIImageView = UIImageView(frame: frame)
        view.backgroundColor = UIColor.gray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
}
