//
//  ViewController.swift
//  RealmSamples
//
//  Created by 默司 on 2018/1/31.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    lazy var stackViewV = UIStackView()
    lazy var stackViewRow1 = UIStackView()
    lazy var stackViewRow2 = UIStackView()
    lazy var buttonStart = UIButton(type: .roundedRect)
    lazy var buttonStep1 = UIButton(type: .roundedRect)
    lazy var buttonStep2 = UIButton(type: .roundedRect)
    lazy var buttonCancel = UIButton(type: .roundedRect)
    lazy var buttonCommit = UIButton(type: .roundedRect)
    lazy var logView = UITextView()
    
    var realm: Realm!
    
    var todos: Results<TodoItem>!
    var token: NotificationToken?
    var timer: Timer?
    
    var isStarted: Bool = false {
        didSet {
            self.buttonStart.isEnabled = !isStarted
            
            self.buttonCancel.isEnabled = isStarted
            self.buttonCommit.isEnabled = isStarted
            self.buttonStep1.isEnabled = isStarted
            self.buttonStep2.isEnabled = isStarted
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        let config = Realm.Configuration(schemaVersion: 2)
        Realm.Configuration.defaultConfiguration = config
        
        self.realm = try! Realm()
        
        self.view.addSubview(stackViewV)
        self.view.addSubview(logView)
        
        self.stackViewV.layout.top(view.safeAreaLayoutGuide.topAnchor)
            .left(view.safeAreaLayoutGuide.leftAnchor)
            .right(view.safeAreaLayoutGuide.rightAnchor)
        self.logView.layout.top(self.stackViewV.bottomAnchor)
            .left(view.safeAreaLayoutGuide.leftAnchor)
            .right(view.safeAreaLayoutGuide.rightAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
        
        self.stackViewV.addArrangedSubview(stackViewRow1)
        self.stackViewV.addArrangedSubview(stackViewRow2)
        self.stackViewRow1.addArrangedSubview(buttonStart)
        self.stackViewRow1.addArrangedSubview(buttonCancel)
        self.stackViewRow1.addArrangedSubview(buttonCommit)
        self.stackViewRow2.addArrangedSubview(buttonStep1)
        self.stackViewRow2.addArrangedSubview(buttonStep2)
        
        self.stackViewV.axis = .vertical
        self.stackViewV.spacing = 4
        self.stackViewV.distribution = .fillEqually
        
        self.stackViewRow1.axis = .horizontal
        self.stackViewRow1.spacing = 2
        self.stackViewRow1.distribution = .fillEqually
        
        self.stackViewRow2.axis = .horizontal
        self.stackViewRow2.spacing = 2
        self.stackViewRow2.distribution = .fillProportionally
        
        self.buttonStart.setTitle("Start", for: .normal)
        self.buttonCancel.setTitle("Cancel", for: .normal)
        self.buttonCommit.setTitle("Commit", for: .normal)
        self.buttonStep1.setTitle("New", for: .normal)
        self.buttonStep2.setTitle("Random Remove", for: .normal)
        
        self.logView.font = UIFont.systemFont(ofSize: 16)
        self.logView.text = "log messages here"
        self.logView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        self.view.layoutIfNeeded()
        
        self.buttonStart.addTarget(self, action: #selector(beginWrite), for: .touchUpInside)
        self.buttonCancel.addTarget(self, action: #selector(cancelWrite), for: .touchUpInside)
        self.buttonCommit.addTarget(self, action: #selector(commitWrite), for: .touchUpInside)
        self.buttonStep1.addTarget(self, action: #selector(newRecord), for: .touchUpInside)
        self.buttonStep2.addTarget(self, action: #selector(modifyRecord), for: .touchUpInside)
        
        self.isStarted = false
        self.refresh()
    }

    deinit {
        self.token?.invalidate()
        self.timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func autoInsert() {
        DispatchQueue.global().async {
            let realm = try! Realm()
            realm.beginWrite()
            
            for _ in 1...5 {
                let df = DateFormatter()
                df.dateFormat = "mm:ss"
                
                let todo = TodoItem()
                todo.title = df.string(from: Date())
                
                realm.add(todo)
                
                Thread.sleep(forTimeInterval: TimeInterval(arc4random_uniform(2) + 1))
            }
            
            try! realm.commitWrite()
            
            self.autoInsert()
        }
    }
    
    func refresh() {
        self.token?.invalidate()
//        self.todos = realm.objects(TodoItem.self)
        self.todos = realm.objects(TodoItem.self).sorted(byKeyPath: "created", ascending: false)
        self.token = todos.observe({[weak self] (change) in
            guard let _ = self else { return }
            
            switch change {
            case .initial(_):
                print("===== INIT =====")
            case .update(let results, let deletions, let insertions, let modifications):
                print("==== UPDATE as \(Date()) ====")
                print("row count: \(results.count)")
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                print("================")
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    @objc func beginWrite() {
        self.realm.beginWrite()
        self.isStarted = true
        self.logView.text = "====== \nstarted at \(Date()) \n" + self.logView.text
    }
    
    @objc func cancelWrite() {
        self.realm.cancelWrite()
        self.isStarted = false
        self.logView.text = "canceled at \(Date()) \n" + self.logView.text
    }
    
    @objc func commitWrite() {
        try! self.realm.commitWrite()
        self.isStarted = false
        self.logView.text = "commited at \(Date()) \n" + self.logView.text
    }
    
    @objc func newRecord() {
        let df = DateFormatter()
        df.dateFormat = "mm:ss"
        
        let todo = TodoItem()
        todo.title = df.string(from: Date())
        
        realm.add(todo)
        
        self.logView.text = "new at \(Date()) : \(todo.title)\n" + self.logView.text
    }
    
    @objc func modifyRecord() {
        let count = todos.count
        
        if count == 0 { return }
        let idx = arc4random_uniform(UInt32(count - 1))
        let todo = todos[Int(idx)]

//        todo.title = "1234"
//        todo.created = Date()
        realm.delete(todo)
        
        self.logView.text = "delete at \(Date()) : \(todo.title)\n" + self.logView.text
    }
}

class TodoItem: Object {
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = "(Empty)"
    @objc dynamic var created: Date = Date()
    @objc dynamic var isDone: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension UIView {
    var layout: MLAutolayout { return MLAutolayout(view: self) }
}

class MLAutolayout {
    var view: UIView
    
    init(view: UIView) {
        self.view = view
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    func constraint(attr: NSLayoutAttribute, _ relation: NSLayoutRelation = .equal, _ to: Any? = nil, attr toAttr: NSLayoutAttribute = .notAnAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) -> MLAutolayout {
        let layout = NSLayoutConstraint(item: view, attribute: attr, relatedBy: relation, toItem: to, attribute: toAttr, multiplier: multiplier, constant: constant)
        
        layout.isActive = true
        
        return self
    }
    
    @discardableResult
    func top(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) -> MLAutolayout {
        let c = view.topAnchor.constraint(equalTo: anchor, constant: constant)
        c.isActive = true
        return self
    }
    
    @discardableResult
    func left(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, multiplier: CGFloat = 1) -> MLAutolayout {
        let c = view.leftAnchor.constraint(equalTo: anchor, constant: constant)
        c.isActive = true
        return self
    }
    
    @discardableResult
    func bottom(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0, multiplier: CGFloat = 1) -> MLAutolayout {
        let c = view.bottomAnchor.constraint(equalTo: anchor, constant: constant)
        c.isActive = true
        return self
    }
    
    @discardableResult
    func right(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0, multiplier: CGFloat = 1) -> MLAutolayout {
        let c = view.rightAnchor.constraint(equalTo: anchor, constant: constant)
        c.isActive = true
        return self
    }
}

