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


private struct Request {
    var id: String
    var method: String
    var params: Dictionary<String, AnyObject>?
    var handleResponse: (JSON) -> Void
    var client: AriaClient?
    
    init(method: String,
         params: [String:AnyObject]? = nil,
         handleResponse: (JSON) -> Void, client: AriaClient? = nil) {
        self.id = method
        self.method = method
        self.params = params
        self.handleResponse = handleResponse
        self.client = client
    }
    
    func send() {
        guard let client = self.client,
            websocket = client.websocket else {
            return
        }
        
        var jsonDict: [String: AnyObject] = ["jsonrpc": "2.0", "method": method, "id": id]
        if let params = params {
            // add secret key
//            if let secret = client.secret {
//                jsonDict["secret"] = secret
//            }
            
            jsonDict["params"] = params
        }
        
        let jsonString = "\(JSON(jsonDict))"
        
        // for debug
        print("sending request: " + jsonString)
        
        websocket.send(jsonString)
        client.requestDict[id] = self
    }
}


public class AriaClient: NSObject {
    
    private var url: String?
    private var websocket: WebSocket?
    private var requestDict = [String: Request]()
    private var secret: String?
    
    public var globalStat = GlobalStat.init()
    
    public init(_ url: String) {
        self.url = url
    }
    
    public func connect() {
        
        guard let url = url else {
            return
        }
        
        self.websocket = WebSocket.init(url)
        self.websocket?.event.open = {
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Connected.rawValue, object: nil)
        }
        
        self.websocket?.event.close = {code, reason, wasClean in
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Disconnected.rawValue, object: nil)
        }
        
        self.websocket?.event.error = { error in
            print(error)
        }
        
        self.websocket?.event.message = { message in
            
            print(message)
            
            let json = JSON.parse(message as! String)
            
            guard let id = json["id"].string, request = self.requestDict[id]  else {
                print("No Related Reuqest found for this message")
                return
            }
            
            request.handleResponse(json)
            self.requestDict.removeValueForKey(id)
        }
    }
    
    private func generateRequest(method: String,
                                 params: [String:AnyObject]? = nil,
                                 handleResponse: (JSON) -> Void) -> Request {
        let request = Request.init(method: method, params: params, handleResponse: handleResponse, client: self)
        
        return request
    }
}


// Aria2 methods
extension AriaClient {
    
    public func getGlobalStat(completion: (Result<GlobalStat>) -> Void) {
        self.generateRequest("aria2.getGlobalStatd") { (json) in
            if json["result"] == nil {
                // FIXME: error
                let error = NSError.init(domain: "kintoun", code: 0, userInfo: nil)
                completion(.Error(error))
            } else {
                let stat = GlobalStat.init(json["result"])
                completion(.Success(stat))
            }
        }.send()
    }
    
    
    public func addUri(uri: [String], completion: (Result<String>) -> Void) {
        self.generateRequest("aria2.addUri") { (json) in
            
        }.send()
    }
    
}


