//
//  ViewController.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var taskTableView: NSTableView!
    
    fileprivate var downloadFolderPath = URL(fileURLWithPath: NSHomeDirectory() + "/Downloads")
    fileprivate var tasks = [AriaClientTask]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // adding notification
        NotificationCenter.default.addObserver(self, selector: #selector(ariaClientConnected), name: NSNotification.Name(rawValue: AriaClientNotificationKey.Connected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ariaClientDisconnected), name: NSNotification.Name(rawValue: AriaClientNotificationKey.Disconnected), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ariaClientDownloadStart), name: NSNotification.Name(rawValue: AriaClientNotificationKey.DownloadStart), object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(ariaClientDownloadComplete), name: NSNotification.Name(rawValue: AriaClientNotificationKey.DownloadComplete), object: nil);
       
        ariaManager.setup()
    }  
    
    @IBAction func createTask(_ sender: AnyObject) {
        let newTaskPanel = NewTaskPanel.init()
        newTaskPanel.beginSheetModalForWindow(self.view.window!) { (response) in
            if response == .ok {
                let urls = newTaskPanel.urlTextField.stringValue.components(separatedBy: ",")
                ariaManager.client.addUri(urls) { (result) in
                    switch result {
                    case let .error(error):
                        print(error)
                    case let .success(value):
                        print(value)
                    }
                }
            }
        }
    }
}



// MARK: Handle Notification -
extension MainViewController {
    
    func ariaClientConnected() {
        
        ariaManager.client.subcribe([.active, .waiting, .stopped]) { (result) in
            switch result {
            case let .error(error):
                print(error)
            case let .success(tasks):
                // temp solution
                if self.tasks.count != tasks.count {
                    self.tasks = tasks
                    self.taskTableView.reloadData()
                } else {
                    var dict = [String: StructWrapper<AriaClientTask>]()
                    for task in tasks {
                        dict[task.gid] = StructWrapper.init(theValue: task)
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "TaskCellUpdateNotification"), object: nil, userInfo: dict)
                }
            }
        }
    }
    
    func ariaClientDisconnected() {
        // show error
    }
    
    func ariaClientDownloadStart(_ notification: Notification) {
        
    }
    
    func ariaClientDownloadComplete(_ notification: Notification) {
        
    }
}


// MARK: TableViewDatasource/Delegate -
extension MainViewController: NSTableViewDelegate, NSTableViewDataSource {
   
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: "TaskCell", owner: self) as! TaskCell
        cell.task = (tasks[row])
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tasks.count
    }
    
}


// MARK: Debug -
extension MainViewController {
    
    @IBAction func prinActiveTasks(_ sender: AnyObject) {
        ariaManager.client.tellActive({ (result) in
            switch result {
            case let .error(error):
                print(error)
            case let .success(tasks):
                self.tasks = tasks
                // TODO: reload tableview
            }
        })
    }
}


class StructWrapper<T> {
    var wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}
