//
//  TodoItem.swift
//  RealmGettingStarted
//
//  Created by 默司 on 2018/1/30.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit

class TodoItem {
    public var title: String
    public var created: Date = Date()
    public var isDone: Bool = false
    
    init(title: String) {
        self.title = title
    }
}
