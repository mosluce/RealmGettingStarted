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
    @IBOutlet weak var stateSegment: UISegmentedControl!
    
    var realm: Realm!
    var items: Results<TodoItem>!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = "TODOs"
        
        self.realm = try! Realm()
        print(realm.configuration.fileURL!)
        
        self.selectState(0)
//        self.items = realm.objects(TodoItem.self).sorted(byKeyPath: "created", ascending: false)
//        self.notificationToken = self.items.observe {[weak self] (changes) in
//            guard let tableView = self?.tableView else { return }
//
//            switch changes {
//            case .initial:
//                // Results are now populated and can be accessed without blocking the UI
//                tableView.reloadData()
//            case .update(_, let deletions, let insertions, let modifications):
//                // Query results have changed, so apply them to the UITableView
//                tableView.beginUpdates()
//                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
//                                     with: .automatic)
//                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
//                                     with: .automatic)
//                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
//                                     with: .automatic)
//                tableView.endUpdates()
//            case .error(let error):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(error)")
//            }
//        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerNib(TodoItemCell.self)
        
        self.titleField.addTarget(self, action: #selector(didTitleFieldChange), for: .editingChanged)
        self.addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        self.stateSegment.addTarget(self, action: #selector(didStateChange), for: .valueChanged)
        
        self.addButton.isEnabled = false
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectState(_ state: Int) {
        self.items = realm.objects(TodoItem.self).sorted(byKeyPath: "created", ascending: false)
        
        switch state {
        case 1:
            self.items = self.items.filter("isDone = %@", false)
        case 2:
            self.items = self.items.filter("isDone = %@", true)
            break
        default:
            break
        }
        
        self.notificationToken?.invalidate()
        self.notificationToken = self.items.observe {[weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    @objc func didStateChange() {
        self.selectState(self.stateSegment.selectedSegmentIndex)
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
//        self.tableView.beginUpdates()
//        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        self.tableView.endUpdates()
        self.titleField.text = ""
    }
}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TodoItemCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let item = items[indexPath.row]
        
        cell.selectionStyle = .none
        cell.item = item
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        try! realm.write {
            items[indexPath.row].isDone = !items[indexPath.row].isDone
        }
//        self.tableView.beginUpdates()
//        self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            try! realm.write {
                realm.delete(self.items[indexPath.row])
            }
//            items.remove(at: indexPath.row)
//            self.tableView.beginUpdates()
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.tableView.endUpdates()
            break
        case .insert:
            break
        case .none:
            break
        }
    }
}
