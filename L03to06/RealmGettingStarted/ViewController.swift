//
//  ViewController.swift
//  RealmGettingStarted
//
//  Created by 默司 on 2018/1/30.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var realm: Realm!
    var items: Results<TodoItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "TODOs"
        
        self.realm = try! Realm()
        print(self.realm.configuration.fileURL!)
        self.items = realm.objects(TodoItem.self).sorted(byKeyPath: "created", ascending: false)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoItemCell")
        
        self.titleField.addTarget(self, action: #selector(didTitleFieldChange), for: .editingChanged)
        self.addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        
        self.addButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didTitleFieldChange() {
        if let text = self.titleField.text {
            self.addButton.isEnabled = !text.isEmpty
        } else {
            self.addButton.isEnabled = false
        }
    }

    @objc func addItem() {
        try! realm.write {
            let item = realm.create(TodoItem.self)
            item.title = titleField.text!
        }
//        self.items.insert(TodoItem(title: titleField.text!), at: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        self.titleField.text = ""
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = items[indexPath.row]
        
        cell.selectionStyle = .none
        
        if item.isDone {
            cell.textLabel?.text = "✔︎ \(item.title)"
        } else {
            cell.textLabel?.text = "\(item.title)"
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        try! realm.write {
            items[indexPath.row].isDone = !items[indexPath.row].isDone
        }
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            try! realm.write {
                realm.delete(self.items[indexPath.row])
            }
//            items.remove(at: indexPath.row)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            break
        case .insert:
            break
        case .none:
            break
        }
    }
}
