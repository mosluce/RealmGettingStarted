//
//  TodoItemCell.swift
//  RealmGettingStarted
//
//  Created by 默司 on 2018/1/30.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import RealmSwift

class TodoItemCell: UITableViewCell {
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!
    
    var item: TodoItem! {
        didSet {
            if item.isDone {
                self.stateLabel.text = "✔︎"
            } else {
                self.stateLabel.text = ""
            }
            
            self.titleField.text = item.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.titleField.addTarget(self, action: #selector(didItemChange), for: .editingDidEnd)
    }
    
    @objc func didItemChange() {
        if let text = titleField.text {
            let realm = try! Realm()
            
            try! realm.write {
                item.title = text
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
