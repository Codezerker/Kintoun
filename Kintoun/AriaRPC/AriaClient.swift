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

public struct AriaClientNotificationKey {
    static let Connected = "AriaClientConnected"
    static let Disconnected = "AriaClientDisconnected"
    static let GlobalStatChanged = "AriaClientGlobalStatChanged"
    
    static let DownloadStart = "AriaClientDownloadStart"
    static let DownloadComplete = "AriaClientDownloadComplete"
}


private struct Request {
    var id: String
    var method: String
    var params: [AnyObject]?
    var option: AriaClientOption?
    var handleResponse: ((JSON) -> Void)?
    
    init(method: String) {
        self.id = method + "\(Int(NSDate.init().timeIntervalSince1970))"
        self.method = method
    }
}


public class AriaClient: NSObject {
    
    private var url: String?
    private var websocket: WebSocket?
    private var requestDict = [String: Request]()
    private var secret: String?
    private var globalOptions = [String: AnyObject]()
    
    public var globalStat = GlobalStat.init()
    
    public init(_ url: String) {
        self.url = url
        
        // defualt settings
        globalOptions[AriaClientOption.dir] = NSHomeDirectory() +  "/Downloads/"
    }
    
    
    public func connect() {
        
        guard let url = url else {
            return
        }
        
        self.websocket = WebSocket.init(url)
        self.websocket?.event.open = {
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Connected, object: nil)
            print("Open...")
        }
        
        self.websocket?.event.close = {code, reason, wasClean in
            NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.Disconnected, object: nil)
            print("Close...")
        }
        
        self.websocket?.event.error = { error in
            print(error)
        }
        
        self.websocket?.event.message = { message in
            
            print(message)
            
            let json = JSON.parse(message as! String)
            
            // handle notification from aria server
            if let method = json["method"].string {
                switch method {
                case "aria2.onDownloadStart":
                    let params = json["params"].array?.first?.dictionaryObject
                    NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.DownloadStart, object: nil, userInfo: params)
                    return
                case "aria2.onDownloadComplete":
                    let params = json["params"].array?.first?.dictionaryObject
                    NSNotificationCenter.defaultCenter().postNotificationName(AriaClientNotificationKey.DownloadComplete, object: nil, userInfo: params)
                    return
                default:
                    break
                }
            }
            
            guard let id = json["id"].string, request = self.requestDict[id]  else {
                print("No Related Reuqest found for this message")
                return
            }
            
            request.handleResponse?(json)
            self.requestDict.removeValueForKey(id)
        }
    }
    
    
    private func generateRequest(method: String,
                                 params: [AnyObject]? = nil,
                                 option: AriaClientOption? = nil,
                                 handleResponse: (JSON) -> Void) -> Request {
        var request = Request.init(method: method)
        request.params = params
        request.option = option
        request.handleResponse = handleResponse
        return request
    }
    
    private func send(request: Request) {
        guard let websocket = self.websocket else {
            return
        }
        
        var jsonDict: [String: AnyObject] = ["jsonrpc": "2.0", "method": request.method, "id": request.id]
        if let params = request.params {
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
        self.requestDict[request.id] = request
    }
}

extension NSError {
    private convenience init(domain: String, json: JSON) {
        let code = json["code"].int ?? 0
        self.init(domain: "client.aria.kintoun", code: code, userInfo: json.dictionaryObject)
    }
}

// Aria2 methods
extension AriaClient {
    
    public func getGlobalStat(completion: (Result<GlobalStat>) -> Void) {
        let request = self.generateRequest("aria2.getGlobalStatd") { (json) in
            if json["result"] == nil {
                let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: json["error"])
                completion(.Error(error))
            } else {
                let stat = GlobalStat.init(json["result"])
                completion(.Success(stat))
            }
        }
        
        self.send(request)
    }
    
    
    public func tellActive(completion:(Result<Array<AriaClientTask>>) -> Void) {
        let request = self.generateRequest("aria2.tellActive") { (json) in
            guard let array = json["result"].array else {
                let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: json["error"])
                completion(.Error(error))
                return
            }

            var tasks = [AriaClientTask]()
            for taskJSON in array {
                if let task = AriaClientTask.init(json: taskJSON) {
                    tasks.append(task)
                } else {
                    let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: nil)
                    completion(.Error(error))
                    return
                }
            }
            completion(.Success(tasks))
        }
        
        self.send(request)
    }
    
    
    public func getGlobalSettings() {
        let request = self.generateRequest("aria2.getGlobalOption") { (json) in
            if json["result"] == nil {
                print(json["error"])
                // TODO: return error
            } else {
                print(json["result"])
            }
        }
        
        self.send(request)
    }
    
    
    public func addUri(uris: [String], options:[String: AnyObject]? = nil, completion: (Result<String>) -> Void) {
        // merge global options
        var combinedOptions = globalOptions
        if let options = options {
            for (key, value) in options {
                combinedOptions[key] = value
            }
        }
        
        let request = self.generateRequest("aria2.addUri", params: [uris, combinedOptions]) { (json) in
            guard let gid = json["result"].string else {
                let error = NSError.init(domain: "addUri.ariaClient.Kintoun", json: json["error"])
                completion(.Error(error))
                return
            }
            completion(.Success(gid))
        }
        
        self.send(request)
    }
    
    
    
}


