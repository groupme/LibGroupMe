//
//  LibGroupMe.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/17/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//


import Foundation


/** 
    public interface for networking, database access
*/
public class GroupMe: NSObject {
    
    private(set) public var apiClient : APIClient!
    private(set) public var storage : Storage!
    
    /**
        injects independent networking, database storage layers
    */
    required public init(apiClient: APIClient, storage:Storage) {
        self.apiClient = apiClient
        self.storage = storage
        super.init()
    }
    
    /**
        :param: updated - a block that gets called back with results(twice, once with cached data, again with fetched data, with the resultant powerups
                :param: _ - the list of
                :param: isFromCache - `true` whether powerups were fetched from database, `false` if they were fetched from network
    */
    public func powerups(updated: ((Array<Powerup>?, isFromCache:Bool) -> Void)) {
        
        self.storage.fetchPowerups({(cachedPowerups: Array<Powerup>?) in
            updated(cachedPowerups, isFromCache:true)
        })
        
        self.apiClient.fetchPowerups({(powerupsDict: NSDictionary) in
            var updatedPowerups: Array = Array<Powerup>()
            if let powerupInfos = powerupsDict["powerups"] as? NSArray {
                for p in powerupInfos {
                    updatedPowerups.append(Powerup(info: p as? NSDictionary))
                }
                self.storage.storePowerups(updatedPowerups, completion: { () -> Void in
                })
                updated(updatedPowerups, isFromCache:false)
            }
        })
    }
    
    /**
        :param: updated - a block that gets called back with results (twice, once with cached data, again with fetched data, with the resultant groups
                :param: _ - the list of fetched groups
                :param: isFromCache - `true` whether powerups were fetched from database, `false` if they were fetched from network
    */
    public func groupsIndex(updated: ((Array<Group>?, isFromCache:Bool) -> Void)) {
        self.storage.fetchGroups({(cachedGroups: Array<Group>?) in
            updated(cachedGroups, isFromCache:true)
        });
        
        self.apiClient.fetchGroups({(groupsDict: NSDictionary) in
            var groups: Array = Array<Group>()
            if let groupInfos = groupsDict["response"] as? NSArray {
                for info in groupInfos {
                    groups.append(Group(info: info as! NSDictionary))
                }
            }
            
            self.storage.storeGroups(groups, completion: { () -> Void in
                
            })
            updated(groups, isFromCache:false)
        })
    }
}
