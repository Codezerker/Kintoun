//
//  AriaClientModel.swift
//  Kintoun
//
//  Created by Jesse on 13/04/16.
//  Copyright © 2016 CodeZerker. All rights reserved.
//

import Foundation
import SwiftyJSON

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