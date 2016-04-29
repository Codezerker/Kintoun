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
        case Cancel = 0
        case OK = 1
    }
   
    
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet var newTaskView: NSView!
    
    private var window: NSWindow?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        
        super.init(contentRect: NSMakeRect(0, 0, 420, 80), styleMask: NSTitledWindowMask, backing: .Buffered, defer: false)
        
        NSBundle.mainBundle().loadNibNamed("NewTaskView", owner: self, topLevelObjects: nil)
        
        self.contentView = newTaskView
    }
    
    func beginSheetModalForWindow(window: NSWindow, completionHandler handler: (NewTaskPanelResponse) -> Void) {
        self.window = window
        
        window.beginSheet(self) { (response) in
            handler(NewTaskPanelResponse.init(rawValue: response)!)
        }
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        window?.endSheet(self, returnCode: NewTaskPanelResponse.OK.rawValue)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        window?.endSheet(self, returnCode: NewTaskPanelResponse.Cancel.rawValue)
    }
    
}
