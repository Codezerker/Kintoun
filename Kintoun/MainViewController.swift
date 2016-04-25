//
//  ViewController.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var urlsTextField: NSTextField!
    @IBOutlet weak var savePathLabel: NSTextField!
    
    private var downloadFolderPath = NSURL.fileURLWithPath(NSHomeDirectory() + "/Downloads/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.savePathLabel.stringValue = downloadFolderPath.path!
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didConnectNotification), name: AriaClientNotificationKey.Connected.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(globalStatChanged), name: AriaClientNotificationKey.GlobalStatChanged.rawValue, object: nil)
        
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
    
    @IBAction func saveTo(sender: AnyObject) {
//        let panel = NSOpenPanel.init(contentRect: NSMakeRect(0, 0, 500, 400), styleMask: 0, backing: .Retained, defer: false)
//        panel.canChooseFiles = false
//        panel.canChooseDirectories = true
//        panel.allowsMultipleSelection = false
//        panel.beginSheetModalForWindow(self.view.window!) { (result) in
//            if (result == 1) {
//                print(panel.URL)
//            }
//        }
    }
    
    @IBAction func download(sender: AnyObject) {
        let urls = self.urlsTextField.stringValue.componentsSeparatedByString(",")
        ariaManager.client.addUri(urls) { (result) in
            switch result {
            case let .Error(error):
                print(error)
                break
            case let .Success(value):
                print(value)
                break
            }
        }
    }
}

