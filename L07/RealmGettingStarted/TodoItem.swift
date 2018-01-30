//
//  TodoItem.swift
//  RealmGettingStarted
//
//  Created by 默司 on 2018/1/30.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import RealmSwift

class TodoItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic public var created: Date = Date()
    @objc dynamic public var isDone: Bool = false
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
