//
//  AriaClient.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Foundation
import SwiftWebSocket

//private enum AriaMethods: String {
//    case AddUri         = "aria2.addUri"
//    case AddTorrent     = "aria2.addTorrent"
//    case AddMetalink    = "aria2.addMetalink"
//    case Remove         = "aria2.remove"
//    case ForceRemove    = "aria2.forceRemove"
//    case Pause          = "aria2.pause"
//    case PauseAll       = "aria2.pauseAll"
//    case ForcePause     = "aria2.forcePause"
//    case ForcePauseAll  = "aria2.forcePauseAll"
//    case Unpause        = "aria2.unpause"
//    case UnpauseAll     = "aria2.unpauseAll"
//    case TellStatus     = "aria2.tellStatus"
//    case GetUris        = "aria2.getUris"
//    case GetFiles       = "aria2.getFiles"
//}

enum AriaClientNotificationKey: String {
    case Connected = "AriaClientConnected"
    case Disconnected = "AriaClientDisconnected"
}


extension NSDictionary {
    func jsonString() -> String? {
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(self, options: [])
            return String.init(data: data, encoding: NSUTF8StringEncoding)
        } catch _ {
            return nil
        }
    }
}



public class AriaClient: NSObject {
    
    private var url: String?
    private var websocket: WebSocket!
    
    public init(_ url: String) {
        self.url = url
    }
    
    public func connect() {
        
        guard let url = url else {
            return
        }
        
        self.websocket = WebSocket.init(url)
        self.websocket.event.open = {
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Connected.rawValue, object: nil)
        }
        
        self.websocket.event.close = {code, reason, wasClean in
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Disconnected.rawValue, object: nil)
        }
        
        self.websocket.event.error = { error in
            print(error)
        }
        
        self.websocket.event.message = { message in
            self.handleMessage(message as! String)
        }
    }
    
    private func handleMessage(message: String) {
        print(message)
    }
}

// Aria2 methods
extension AriaClient {
    
    public func getGlobalStat() {
        let jsonDict = ["jsonrpc": "2.0", "method": "aria2.getGlobalStat", "id": ""] as NSDictionary
        if let message = jsonDict.jsonString() {
            self.websocket.send(message)
        }
    }
}
