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
    
    private var downloadFolderPath = NSURL.fileURLWithPath(NSHomeDirectory() + "/Downloads")
    private var tasks = [AriaClientTask]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // adding notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ariaClientConnected), name: AriaClientNotificationKey.Connected, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ariaClientDisconnected), name: AriaClientNotificationKey.Disconnected, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ariaClientDownloadStart), name: AriaClientNotificationKey.DownloadStart, object: nil);
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ariaClientDownloadComplete), name: AriaClientNotificationKey.DownloadComplete, object: nil);
       
        ariaManager.setup()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
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



// MARK: Handle Notification -
extension MainViewController {
    
    func ariaClientConnected() {
        
        ariaManager.client.subcribe([.Active, .Waiting, .Stopped]) { (result) in
            switch result {
            case let .Error(error):
                print(error)
            case let .Success(tasks):
                // temp solution
                if self.tasks.count != tasks.count {
                    self.tasks = tasks
                    self.taskTableView.reloadData()
                } else {
                    var dict = [String: StructWrapper<AriaClientTask>]()
                    for task in tasks {
                        dict[task.gid] = StructWrapper.init(theValue: task)
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("TaskCellUpdateNotification", object: nil, userInfo: dict)
                }
            }
        }
    }
    
    func ariaClientDisconnected() {
        // show error
    }
    
    func ariaClientDownloadStart(notification: NSNotification) {
        
    }
    
    func ariaClientDownloadComplete(notification: NSNotification) {
        
    }
}


// MARK: TableViewDatasource/Delegate -
extension MainViewController: NSTableViewDelegate, NSTableViewDataSource {
    
   
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.makeViewWithIdentifier("TaskCell", owner: self) as! TaskCell
        cell.task = (tasks[row])

        return cell
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tasks.count
    }
    
}



// MARK: Debug -
extension MainViewController {
    
    @IBAction func prinActiveTasks(sender: AnyObject) {
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


class StructWrapper<T> {
    var wrappedValue: T
    init(theValue: T) {
        wrappedValue = theValue
    }
}