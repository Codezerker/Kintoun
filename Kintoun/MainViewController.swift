//
//  ViewController.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
    }
    
    func globalStatChanged() {
        
    }
}

