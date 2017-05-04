//
//  NewTaskPanel.swift
//  Kintoun
//
//  Created by Jesse on 30/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class NewTaskPanel: NSPanel {

    enum NewTaskPanelResponse: Int {
        case cancel = 0
        case ok = 1
    }
   
    
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet var newTaskView: NSView!
    
    fileprivate var window: NSWindow?
       
    init() {
        
        super.init(contentRect: NSMakeRect(0, 0, 420, 80), styleMask: NSTitledWindowMask, backing: .buffered, defer: false)
        
        Bundle.main.loadNibNamed("NewTaskView", owner: self, topLevelObjects: nil)
        
        self.contentView = newTaskView
    }
    
    func beginSheetModalForWindow(_ window: NSWindow, completionHandler handler: @escaping (NewTaskPanelResponse) -> Void) {
        self.window = window
        
        window.beginSheet(self) { (response) in
            handler(NewTaskPanelResponse.init(rawValue: response)!)
        }
    }
    
    @IBAction func okButtonClicked(_ sender: AnyObject) {
        window?.endSheet(self, returnCode: NewTaskPanelResponse.ok.rawValue)
    }
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        window?.endSheet(self, returnCode: NewTaskPanelResponse.cancel.rawValue)
    }
    
}
