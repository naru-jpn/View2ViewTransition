//
//  MenuViewController.swift
//  View2ViewTransitionExample
//
//  Created by naru on 2016/09/06.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(self.tableView)
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let Font: UIFont = UIFont.systemFontOfSize(15.0)
        static let ButtonSize: CGSize = CGSize(width: 200.0, height: 44.0)
    }
    
    // MARK: Elements
    
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(TableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}

extension MenuViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterViewWithIdentifier("header")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        self.configulerCell(cell, at: indexPath)
        return cell
    }
    
    func configulerCell(cell: UITableViewCell, at indexPath: NSIndexPath) {
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.font = UIFont.systemFontOfSize(14.0)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Present and Dismiss"
        case 1:
            cell.textLabel?.text = "Push and Pop"
        default:
            break
        }
    }
}

extension MenuViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewSectionHeader.Constants.Height
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            self.presentViewController(PresentingViewController(), animated: true, completion: nil)
        case 1:
            self.presentViewController(UINavigationController(rootViewController: PresentingViewController()), animated: true, completion: nil)
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

private class TableViewSectionHeader: UITableViewHeaderFooterView {
    
    struct Constants {
        static let Height: CGFloat = 60.0
        static let Width: CGFloat = UIScreen.mainScreen().bounds.width
        static let Font: UIFont = UIFont.boldSystemFontOfSize(14.0)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let frame: CGRect = CGRect(x: 12.0, y: Constants.Height - ceil(Constants.Font.lineHeight) - 8.0, width: Constants.Width - 24.0, height: ceil(Constants.Font.lineHeight))
        let label: UILabel = UILabel(frame: frame)
        label.font = Constants.Font
        label.text = "Examples of View2View Transition"
        label.textColor = UIColor(white: 0.3, alpha: 1.0)
        return label
    }()
}
