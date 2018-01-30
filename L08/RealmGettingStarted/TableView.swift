//
//  TableView.swift
//  RealmGettingStarted
//
//  Created by 默司 on 2018/1/30.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit

extension UITableView {
    func registerClass<T: UITableViewCell>(_ cellClass: T.Type) {
        let className = String.init(describing: T.self)
        
        register(T.self, forCellReuseIdentifier: className)
    }
    
    func registerNib<T: UITableViewCell>(_ cellClass: T.Type) {
        let className = String.init(describing: T.self)
        register(UINib(nibName: className, bundle: Bundle(for: T.self)), forCellReuseIdentifier: className)
    }
    
    func dequeueReusableCell<T>(forIndexPath indexPath: IndexPath) -> T where T: UITableViewCell {
        let className = String.init(describing: T.self)
        
        guard let cell = dequeueReusableCell(withIdentifier: className, for: indexPath) as? T else {
            preconditionFailure("Unable to dequeue \(T.description()) for indexPath: \(indexPath)")
        }
        
        return cell
    }
}
