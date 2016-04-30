//
//  TaskCell.swift
//  Kintoun
//
//  Created by Jesse on 30/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class TaskCell: NSView {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var detailLabel: NSTextField!
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
