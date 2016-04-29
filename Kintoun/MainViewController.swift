//
//  ViewController.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    private var downloadFolderPath = NSURL.fileURLWithPath(NSHomeDirectory() + "/Downloads/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectNotification), name: AriaClientNotificationKey.Connected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(globalStatChanged), name: AriaClientNotificationKey.GlobalStatChanged, object: nil)
        
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
    
    func globalStatChanged() {
        
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

