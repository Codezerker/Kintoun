//
//  AriaClient.swift
//  Kintoun
//
//  Created by Jesse on 11/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Foundation
import SwiftWebSocket
import SwiftyJSON

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
    case GlobalStatChanged = "AriaClientGlobalStatChanged"
}

public class AriaClient: NSObject {
    
    private var url: String?
    private var websocket: WebSocket!
    
    public var globalStat = GlobalStat.init()
    
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
        
        if let data = message.dataUsingEncoding(NSUTF8StringEncoding) {
            let json = JSON(data)
            guard let id = json["id"].string  else {
                print("No Message ID")
                return
            }
            
            switch id {
            case "aria2.getGlobalStat":
                handleGlobalStat(json)
                break
            default:
                break
            }
        }
        
    }
}

// Aria2 methods
extension AriaClient {
    
    public func getGlobalStat() {
        let jsonDict = ["jsonrpc"   : "2.0",
                        "method"    : "aria2.getGlobalStat",
                        "id"        : "aria2.getGlobalStat"]
        
        if let message = JSON(jsonDict).string {
            self.websocket.send(message)
        }
    }
}


// callback
extension AriaClient {
    
    private func handleGlobalStat(json: JSON) {
        let newGlobalStat = GlobalStat.init(json)
        if globalStat != newGlobalStat {
            globalStat = newGlobalStat
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.GlobalStatChanged.rawValue, object: nil)
        }
        
        
    }
}
