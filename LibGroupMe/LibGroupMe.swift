//
//  LibGroupMe.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/17/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//


import Foundation


// public interface for networking, database access
public class GroupMe: NSObject {
    
    private(set) public var apiClient : APIClient!
    private(set) public var storage : Storage!
    
    required public init(apiClient: APIClient, storage:Storage) {
        self.apiClient = apiClient
        self.storage = storage
        super.init()
    }
    
    // calls back updated twice, once with cached data, again with fetched data
    public func powerups(updated: ((Array<Powerup>?, isFromCache:Bool) -> Void)) {
        self.storage.fetchPowerups({(cachedPowerups: Array<Powerup>?) in
            updated(cachedPowerups, isFromCache:true)
        })
        self.apiClient.fetchPowerups({(powerupsDict: NSDictionary) in
            var updatedPowerups: Array = Array<Powerup>()
            if let powerupInfos = powerupsDict["powerups"] as? NSArray {
                for p in powerupInfos {
                    updatedPowerups.append(Powerup(info: p as? NSDictionary))
                    self.storage.storePowerups(updatedPowerups, completion: { () -> Void in
                    })
                }
                updated(updatedPowerups, isFromCache:false)
            }
        })
    }
}
