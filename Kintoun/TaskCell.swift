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
    @IBOutlet weak var iconImageView: NSImageView!

    var gid: String?
    
    private lazy var byteCountFormatter: NSByteCountFormatter = {
        var formatter = NSByteCountFormatter.init()
        formatter.countStyle = .File
        return formatter
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTaskNotification), name: "TaskCellUpdateNotification", object: nil)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    func updateTask(task: AriaClientTask) {

        let completeLength = byteCountFormatter.stringFromByteCount(task.completedLength)
        let totalLength = byteCountFormatter.stringFromByteCount(task.totalLength)
        let speed = byteCountFormatter.stringFromByteCount(task.downloadSpeed)
        detailLabel.stringValue = "\(completeLength) of \(totalLength) at \(speed)/s"

        
        var path: NSURL?
        if task.files.count > 0 {
            if (task.files[0].uris.count > 0) {
                path = task.files[0].path ?? task.files[0].uris[0].uri
            } else {
                path = task.files[0].path
            }
        }
        
        nameLabel.stringValue = path?.lastPathComponent ?? "Unknown"
        iconImageView.image = NSWorkspace.sharedWorkspace().iconForFileType(path?.pathExtension ?? "")
    }
    
    func updateTaskNotification(notification: NSNotification) {
        guard let gid = gid, userInfo = notification.userInfo, task = userInfo[gid] as? StructWrapper<AriaClientTask> else {
            return
        }
        
        updateTask(task.wrappedValue)
    }
}
