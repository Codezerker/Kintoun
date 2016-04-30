//
//  AriaClientModel.swift
//  Kintoun
//
//  Created by Jesse on 13/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Result<T> {
    case Success(T)
    case Error(ErrorType)
}


public struct AriaClientTask {
    
    enum TaskStatus: String {
        case Active     = "active"
        case Waiting    = "waiting"
        case Paused     = "paused"
        case Error      = "error"
        case Complete   = "complete"
        case Removed    = "removed"
    }
    
    
    struct AriaClientFile {
        let index: UInt
        let length: UInt64
        let completeLength: UInt64
        let path: String
        // selected, uris
        
        init(json: JSON) {
            self.index = json["index"].uIntValue
            self.path = json["path"].stringValue
            self.length = json["length"].uInt64Value
            self.completeLength = json["completeLength"].uInt64Value
        }
    }
    
    
    let gid: String
    let status: TaskStatus
    let totalLength: UInt64
    let completedLength: UInt64
    let uploadLength: UInt64
    let downloadSpeed: UInt64
    let uploadSpeed: UInt64
    let errorCode: Int?
    let errorMessage: String?
    let dir: String?
    let files: [AriaClientFile]

    init(gid: String, status: TaskStatus) {
        self.gid = gid
        self.status = status
        self.totalLength = 0
        self.completedLength = 0
        self.uploadLength = 0
        self.downloadSpeed = 0
        self.uploadSpeed = 0
        self.errorCode = nil
        self.errorMessage = nil
        self.dir = nil
        self.files = []
    }
    
    init?(json: JSON) {
        guard let gid = json["gid"].string,
            statusRaw = json["status"].string,
               status = TaskStatus.init(rawValue: statusRaw) else {
            return nil
        }
        
        self.gid = gid
        self.status = status
        self.totalLength = json["totalLength"].uInt64Value
        self.completedLength = json["completedLength"].uInt64Value
        self.uploadLength = json["uploadLength"].uInt64Value
        self.uploadSpeed = json["uploadSpeed"].uInt64Value
        self.downloadSpeed = json["downloadSpeed"].uInt64Value
        self.errorCode = json["errorCode"].int
        self.errorMessage = json["errorMessage"].string
        self.dir = json["dir"].string

        self.files = json["files"].array?.map({ (json) -> AriaClientFile in
            return AriaClientFile.init(json: json)
        }) ?? []
        
    }
    
    // files
    // bitfield, infoHash, numSeeders, seeder, piceLength, numPieces
    // connections, followedBy, following, belongsTo
}



public struct GlobalStat : Equatable {
    var downloadSpeed: Int
    var uploadSpeed: Int
    var numActive: Int
    var numStopped: Int
    var numStoppedTotal: Int
    var numWaiting: Int
    
    public init(downloadSpeed: Int = 0,
         uploadSpeed: Int = 0,
         numActive: Int = 0,
         numStopped: Int = 0,
         numStoppedTotal: Int = 0,
         numWaiting: Int = 0) {
        
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
        self.numActive = numActive
        self.numStopped = numStopped
        self.numStoppedTotal = numStoppedTotal
        self.numWaiting = numWaiting
    }
    
    public init(_ json: JSON) {
        self.downloadSpeed = json["downloadSpeed"].intValue
        self.uploadSpeed = json["uploadSpeed"].intValue
        self.numActive = json["numActive"].intValue
        self.numStopped = json["numStopped"].intValue
        self.numStoppedTotal = json["numStoppedTotal"].intValue
        self.numWaiting = json["numWaiting"].intValue
    }
}

public func ==(lhs: GlobalStat, rhs: GlobalStat) -> Bool {
    return lhs.downloadSpeed == rhs.downloadSpeed &&
        lhs.uploadSpeed == rhs.uploadSpeed &&
        lhs.numActive == rhs.numActive &&
        lhs.numStopped == rhs.numStopped &&
        lhs.numStoppedTotal == rhs.numStoppedTotal &&
        lhs.numWaiting == rhs.numWaiting
}