//
//  AriaManager.swift
//  Kintoun
//
//  Created by Jesse on 12/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Foundation

struct AriaServer {
    var address: String
    var port: String
    var rpcPath: String
    var isRemote: Bool
    
    func path() -> String {
        return address + ":" + port + "/" + rpcPath
    }
}


public class AriaManager: NSObject {
    
    var client: AriaClient!
    var serverTask: NSTask!
    
    public func setup() {
        
        //TODO: read from userdefualts or pass in
        let server = AriaServer.init(address: "ws://127.0.0.1",
                                     port: "6800",
                                     rpcPath: "jsonrpc",
                                     isRemote: false)
        
        if !server.isRemote {
            // start local server
            let path = NSBundle.mainBundle().pathForResource("aria2c", ofType: nil);
            serverTask = NSTask.init()
            serverTask.launchPath = path
            serverTask.arguments = ["--enable-rpc", "--rpc-listen-all"]
            serverTask.launch()
            
            // temporary solution
            sleep(1)
        }
        
        print(server.path())
        
        client = AriaClient.init(server.path())
        client.connect()
    }
    
}


let ariaManager = AriaManager.init()