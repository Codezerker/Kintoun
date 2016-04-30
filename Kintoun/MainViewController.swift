//
//  ViewController.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    private var downloadFolderPath = NSURL.fileURLWithPath(NSHomeDirectory() + "/Downloads")
    
    private var tasks = [AriaClientTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectNotification), name: AriaClientNotificationKey.Connected, object: nil)
       
        ariaManager.setup()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func didConnectNotification() {
        print("connected!")
        
        ariaManager.client.getGlobalSettings()
        
//        ariaManager.client.getGlobalStat() { (result) in
//            switch result {
//            case let .Success(stat):
//                print("get global stat: + \(stat)")
//                break
//            case let .Error(error):
//                print(error)
//                break
//            }
//        }
    }
    
    func getTasks(activeOnly: Bool) {
        if activeOnly {
            ariaManager.client.tellActive({ (result) in
                switch result {
                case let .Error(error):
                    print(error)
                case let .Success(tasks):
                    self.tasks = tasks
                    // TODO: reload tableview
                }
            })
        }
    }
    
    
    @IBAction func createTask(sender: AnyObject) {
        let newTaskPanel = NewTaskPanel.init()
        newTaskPanel.beginSheetModalForWindow(self.view.window!) { (response) in
            if response == .OK {
                let urls = newTaskPanel.urlTextField.stringValue.componentsSeparatedByString(",")
                ariaManager.client.addUri(urls) { (result) in
                    switch result {
                    case let .Error(error):
                        print(error)
                    case let .Success(value):
                        print(value)
                    }
                }
            }
        }
    }
}


extension MainViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        
        let cell = tableView.makeViewWithIdentifier("TaskCell", owner: self)
        
        
        return nil
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tasks.count
    }
    
}



// MARK - Debug
extension MainViewController {
    
    @IBAction func prinActiveTasks(sender: AnyObject) {
        self.getTasks(true)
    }
}
