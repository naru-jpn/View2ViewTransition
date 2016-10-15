//
//  MenuViewController.swift
//  View2ViewTransitionExample
//
//  Created by naru on 2016/09/06.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public class MenuViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        self.view.addSubview(self.tableView)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !self.isViewControllerInitialized else {
            return
        }
        self.isViewControllerInitialized = true
        self.present(PresentingViewController(), animated: true, completion: nil)
    }
    
    // MARK: Constants
    
    private struct Constants {
        static let Font: UIFont = UIFont.systemFont(ofSize: 15.0)
        static let ButtonSize: CGSize = CGSize(width: 200.0, height: 44.0)
    }
    
    // MARK: Elements
    
    private var isViewControllerInitialized: Bool = false
    
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
}

extension MenuViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        self.configulerCell(cell, at: indexPath as NSIndexPath)
        return cell
    }
    
    func configulerCell(_ cell: UITableViewCell, at indexPath: NSIndexPath) {
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
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

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewSectionHeader.Constants.Height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.present(PresentingViewController(), animated: true, completion: nil)
        case 1:
            self.present(UINavigationController(rootViewController: PresentingViewController()), animated: true, completion: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

private class TableViewSectionHeader: UITableViewHeaderFooterView {
    
    struct Constants {
        static let Height: CGFloat = 60.0
        static let Width: CGFloat = UIScreen.main.bounds.width
        static let Font: UIFont = UIFont.boldSystemFont(ofSize: 14.0)
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
