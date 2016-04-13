//
//  AppDelegate.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // read from userdefaults
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // kill aria2c
        NSTask.launchedTaskWithLaunchPath("/usr/bin/killall", arguments: ["aria2c"]).waitUntilExit()
    }

    
//    func echoTest(){
//        let ws = WebSocket("ws://192.168.1.100:6800/jsonrpc")
//
//        ws.event.open = {
//            print("opened")
//            ws.send("{\"method\": \"aria2.getGlobalStat\", \"params\":[], \"id\": 2}")
//        }
//        ws.event.close = { code, reason, clean in
//            print("close")
//        }
//        ws.event.error = { error in
//            print("error \(error)")
//        }
//        ws.event.message = { message in
//            if let text = message as? String {
//                print("recv: \(text)")
//                ws.close()
//            }
//        }
//    }

}

