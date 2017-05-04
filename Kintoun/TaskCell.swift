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

    var task: AriaClientTask? {
        didSet {
            if let task = task {
                updateTask(task)
                setNeedsDisplay(self.bounds)
            }
        }
    }
    
    fileprivate lazy var byteCountFormatter: ByteCountFormatter = {
        var formatter = ByteCountFormatter.init()
        formatter.countStyle = .file
        return formatter
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTaskNotification), name: NSNotification.Name(rawValue: "TaskCellUpdateNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // set progress bar color
        NSColor.init(red: 220.0/255, green: 245.0/255, blue: 1.0, alpha: 1.0).setFill()
        
        // draw progress bar
        var progressBarFrame = NSMakeRect(0, 0, 0, NSHeight(self.bounds))
        if let task = task, task.totalLength != 0 {
            progressBarFrame.size.width = CGFloat(Double(task.completedLength)/Double(task.totalLength) * Double(NSWidth(self.frame)))
        }
        NSRectFill(progressBarFrame)
    }
    
    func updateTask(_ task: AriaClientTask) {

        // update detail info
        let completeLength = byteCountFormatter.string(fromByteCount: task.completedLength)
        let totalLength = byteCountFormatter.string(fromByteCount: task.totalLength)
        let speed = byteCountFormatter.string(fromByteCount: task.downloadSpeed)

        switch task.status {
        case .Active:
            detailLabel.stringValue = "\(completeLength) of \(totalLength) at \(speed)/s"
        case .Waiting:
            if task.completedLength == 0 {
                detailLabel.stringValue = "Waiting"
            } else {
                detailLabel.stringValue = "\(completeLength) of \(totalLength) Waiting"
            }
        case .Paused:
            detailLabel.stringValue = "\(completeLength) of \(totalLength) Paused"
        case .Error:
            detailLabel.stringValue = "Error"
        case .Complete:
            detailLabel.stringValue = "\(completeLength) of \(totalLength) Complete"
        case .Removed:
            detailLabel.stringValue = "Removed"
        }
        
        // update title, icon
        var path: URL?
        if task.files.count > 0 {
            if (task.files[0].uris.count > 0) {
                path = task.files[0].path ?? task.files[0].uris[0].uri
            } else {
                path = task.files[0].path
            }
        }
        
        nameLabel.stringValue = path?.lastPathComponent ?? "Unknown"
        iconImageView.image = NSWorkspace.shared().icon(forFileType: path?.pathExtension ?? "")
    }
    
    func updateTaskNotification(_ notification: Notification) {
        guard let gid = self.task?.gid, let userInfo = notification.userInfo, let task = userInfo[gid] as? StructWrapper<AriaClientTask> else {
            return
        }
        
        if gid == task.wrappedValue.gid {
            self.task = task.wrappedValue
        }
    }
}
