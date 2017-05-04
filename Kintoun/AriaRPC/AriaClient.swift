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


public enum AriaClientTaskType {
    case active
    case waiting
    case stopped
}


private struct Request {
    var id: String
    var method: String
    var params: [Any]?
    var option: AriaClientOption?
    var handleResponse: ((JSON) -> Void)?
    
    init(method: String) {
        self.id = method + "\(Date.init().timeIntervalSince1970)"
        self.method = method
    }
}


open class AriaClient: NSObject {
    
    fileprivate var url: String?
    fileprivate var websocket: WebSocket?
    fileprivate var requestDict = [String: Request]()
    fileprivate var secret: String?
    fileprivate var globalOptions = [String: AnyObject]()
    
    open var globalStat = GlobalStat.init()
    
    public init(_ url: String) {
        self.url = url
        
        // defualt settings
        globalOptions[AriaClientOption.dir] = NSHomeDirectory() +  "/Downloads/" as AnyObject
    }
    
    
    open func connect() {
        
        guard let url = url else {
            return
        }
        
        self.websocket = WebSocket.init(url)
        self.websocket?.event.open = {
            NotificationCenter.default.post(name: Notification.Name(rawValue: AriaClientNotificationKey.Connected), object: nil)
            print("Open...")
        }
        
        self.websocket?.event.close = {code, reason, wasClean in
            NotificationCenter.default.post(name: Notification.Name(rawValue: AriaClientNotificationKey.Disconnected), object: nil)
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
                    NotificationCenter.default.post(name: Notification.Name(rawValue: AriaClientNotificationKey.DownloadStart), object: nil, userInfo: params)
                    return
                case "aria2.onDownloadComplete":
                    let params = json["params"].array?.first?.dictionaryObject
                    NotificationCenter.default.post(name: Notification.Name(rawValue: AriaClientNotificationKey.DownloadComplete), object: nil, userInfo: params)
                    return
                default:
                    break
                }
            }
            
            guard let id = json["id"].string, let request = self.requestDict[id]  else {
                print("No Related Reuqest found for this message")
                return
            }
            
            request.handleResponse?(json)
            self.requestDict.removeValue(forKey: id)
        }
    }
    
    
    fileprivate func generateRequest(_ method: String,
                                 params: [Any]? = nil,
                                 option: AriaClientOption? = nil,
                                 handleResponse: @escaping (JSON) -> Void) -> Request {
        var request = Request.init(method: method)
        request.params = params
        request.option = option
        request.handleResponse = handleResponse
        return request
    }
    
    fileprivate func send(_ request: Request) {
        guard let websocket = self.websocket else {
            return
        }
        
        var jsonDict: [String: AnyObject] = ["jsonrpc": "2.0" as AnyObject, "method": request.method as AnyObject, "id": request.id as AnyObject]
        if let params = request.params {
            // add secret key
            //            if let secret = client.secret {
            //                jsonDict["secret"] = secret
            //            }
            
            jsonDict["params"] = params as AnyObject
        }
        
        let jsonString = "\(JSON(jsonDict))"
        
        // for debug
        print("sending request: " + jsonString)
        
        websocket.send(jsonString)
        self.requestDict[request.id] = request
    }

    
    open func subcribe(_ types: [AriaClientTaskType], callback: @escaping (Result<Array<AriaClientTask>>) -> Void) {

        func getTasks() {
            // TODO: change to multi call
            tellActive { (result) in
                callback(result)
                DispatchQueue.global().async(execute: {
                    sleep(1)
                    DispatchQueue.main.async(execute: { 
                        getTasks()
                    })
                })
            }
        }
        
        getTasks()
    }
}


// Aria2 methods
extension AriaClient {
    
    public func getGlobalStat(_ completion: @escaping (Result<GlobalStat>) -> Void) {
        let request = self.generateRequest("aria2.getGlobalStatd") { (json) in
            if json["result"] == JSON.null {
                let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
            } else {
                let stat = GlobalStat.init(json["result"])
                completion(.success(stat))
            }
        }
        
        self.send(request)
    }
    
    
    public func tellActive(_ completion: @escaping (Result<Array<AriaClientTask>>) -> Void) {
        let request = self.generateRequest("aria2.tellActive") { (json) in
            guard let array = json["result"].array else {
                let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }

            var tasks = [AriaClientTask]()
            for taskJSON in array {
                if let task = AriaClientTask.init(json: taskJSON) {
                    tasks.append(task)
                } else {
                    let error = NSError.init(domain: "getGlobalStat.ariaClient.Kintoun", json: JSON.null)
                    completion(.error(error))
                    return
                }
            }
            completion(.success(tasks))
        }
        
        self.send(request)
    }
    
    
    public func getGlobalSettings() {
        let request = self.generateRequest("aria2.getGlobalOption") { (json) in
            if json["result"] == JSON.null {
                print(json["error"])
                // TODO: return error
            } else {
                print(json["result"])
            }
        }
        
        self.send(request)
    }
    
    
    /* This method adds a new download. uris is an array of HTTP/FTP/SFTP/BitTorrent URIs (strings) pointing to the same resource. It returns the GID of the newly registered download.
     */
    public func addUri(_ uris: [String], options:[String: AnyObject]? = nil, completion: @escaping (Result<String>) -> Void) {
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
                completion(.error(error))
                return
            }
            completion(.success(gid))
        }
        
        self.send(request)
    }
    
    
    /* This method removes the download denoted by gid (string). If the specified download is in progress, it is first stopped. The status of the removed download becomes removed. This method returns GID of removed download.
     */
    public func remove(_ gid: String, force: Bool = false, completion: @escaping (Result<String>) -> Void) {
        let request = self.generateRequest(force ? "aria2.forceRemove" : "aria2.remove", params: [gid]) { (json) in
            guard let gid = json["result"].string else {
                let error = NSError.init(domain: "remove.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success(gid))
        }
        
        self.send(request)
    }
    
    
    /* This method pauses the download denoted by gid (string). The status of paused download becomes paused. If the download was active, the download is placed in the front of waiting queue. While the status is paused, the download is not started. To change status to waiting, use the aria2.unpause() method. This method returns GID of paused download.
     */
    public func pause(_ gid: String, force: Bool = false, completion: @escaping (Result<String>) -> Void) {
        let request = self.generateRequest(force ? "aria2.forcePause" : "aria2.pause", params: [gid]) { (json) in
            guard let gid = json["result"].string else {
                let error = NSError.init(domain: "pause.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success(gid))
        }
        
        self.send(request)
    }
    
    
    /* This method is equal to calling aria2.pause() for every active/waiting download. This methods returns OK.
     */
    public func pauseAll(_ force: Bool = false, completion: @escaping (Result<String>) -> Void) {
        let request = self.generateRequest(force ? "aria2.forcePauseAll" : "aria2.pauseAll") { (json) in
            if json["result"].string != "OK"  {
                let error = NSError.init(domain: "pauseAll.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success("OK"))
        }
        
        self.send(request)
    }
    
    
    /* This method changes the status of the download denoted by gid (string) from paused to waiting, making the download eligible to be restarted. This method returns the GID of the unpaused download.
     */
    public func unpause(_ gid: String, completion: @escaping (Result<String>) -> Void) {
        let request = self.generateRequest("aria2.unpause", params: [gid]) { (json) in
            guard let gid = json["result"].string else {
                let error = NSError.init(domain: "unpause.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success(gid))
        }
        
        self.send(request)
    }
    
    
    /* This method is equal to calling aria2.unpause() for every active/waiting download. This methods returns OK.
     */
    public func unpauseAll(_ completion: @escaping (Result<String>) -> Void) {
        let request = self.generateRequest("aria2.unpauseAll") { (json) in
            if json["result"].string != "OK"  {
                let error = NSError.init(domain: "unpauseAll.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success("OK"))
        }
        
        self.send(request)
    }
    
    
    /* This method removes a completed/error/removed download denoted by gid from memory. If gid is not assigned, it removes all. This method returns OK for success.
     */
    func clearDownloadResult(_ gid: String? = nil, completion: @escaping (Result<String>) -> Void) {
        
        let method: String
        let params: [AnyObject]?
        if let gid = gid {
            method = "aria2.removeDownloadResult"
            params = [gid as AnyObject]
        } else {
            method = "aria2.purgeDownloadResult"
            params = nil
        }
        
        let request = self.generateRequest(method, params: params) { (json) in
            if json["result"].string != "OK"  {
                let error = NSError.init(domain: "addUri.ariaClient.Kintoun", json: json["error"])
                completion(.error(error))
                return
            }
            completion(.success("OK"))
        }
        
        self.send(request)
    }
}


extension NSError {
    fileprivate convenience init(domain: String, json: JSON) {
        let code = json["code"].int ?? 0
        self.init(domain: "client.aria.kintoun", code: code, userInfo: json.dictionaryObject)
    }
}

