//
//  Storage.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/16/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//

import Foundation
import YapDatabase

public class Storage: NSObject {
    
    private(set) public var name: String!
    private(set) public var database: YapDatabase
    private(set) public var backgroundDBConnection: YapDatabaseConnection
    
    static public let sharedInstance = Storage(name:"lib-gm-database")
    
    /**
        :param: name - essentially a name for the .db file that will get created
    */
    required public init(name: String) {
        self.name = name

        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        // http://stackoverflow.com/a/27657631
        var path: String? = nil
        if let documentDirectory: NSURL = urls.first as? NSURL {
            // This is where the database should be in the documents directory
            let finalDatabaseURL = documentDirectory.URLByAppendingPathComponent("\(name).db")
            path = finalDatabaseURL.absoluteString
            if !finalDatabaseURL.checkResourceIsReachableAndReturnError(nil) {
                // Copy the initial file from the application bundle to the documents directory
                if let bundleURL = NSBundle.mainBundle().URLForResource(name, withExtension: "db") {
                    let success = fileManager.copyItemAtURL(bundleURL, toURL: finalDatabaseURL, error: nil)
                    if success {
                        path = finalDatabaseURL.absoluteString
                    } else {
                        println("Couldn't copy file to final location!")
                    }
                } else {
                    println("Couldn't find initial database in the bundle!")
                }
            }
        } else {
            println("Couldn't get documents directory!")
        }
        self.database = YapDatabase(path: path!)
        self.backgroundDBConnection = self.database.newConnection()
        super.init()
    }
    
    private func storeInDefault(array:Array<AnyObject>?, key:String!,completion:(() -> Void)) {
        self.backgroundDBConnection
            .asyncReadWriteWithBlock({ (transaction: YapDatabaseReadWriteTransaction) -> Void in
                transaction.setObject(array, forKey: key, inCollection:"default")
        }, completionBlock: { () -> Void in
            completion()
        })
    }
    
    private func fetchFromDefault(key:String!, completion:(Array<AnyObject>? -> Void)) {
        self.database.newConnection().asyncReadWithBlock({ (transaction: YapDatabaseReadTransaction) -> Void in
            if let o = transaction.objectForKey(key, inCollection: "default") as? Array<AnyObject> {
                completion(o)
            } else {
                println("huh?") // FIXME throw an exception here in Swift 2.0
            }
        }, completionBlock: { () -> Void in
        })
    }
    
    public func storePowerups(powerups: Array<Powerup>, completion:(() -> Void)) {
        self.storeInDefault(powerups, key: "powerups_index", completion: completion)
    }
    
    /**
        fetches `Powerup` objects asynchonously from the store
        :param: completion - the block to call back with the fetched powerups   
    */
    public func fetchPowerups(completion:(Array<Powerup>? -> Void)) {
        self.fetchFromDefault("powerups_index", completion:{(fetched: Array<AnyObject>?) -> Void in
            if let powerups = fetched as? Array<Powerup> {
                completion(powerups)
            } else {
                completion(nil)
            }
        })
    }
    
    public func storeGroups(groups: Array<Group>, completion:(() -> Void)) {
        self.storeInDefault(groups, key: "groups_index", completion: completion)
    }
    
    public func fetchGroups(completion:(Array<Group>? -> Void)) {
        self.fetchFromDefault("groups_index", completion:{(fetched: Array<AnyObject>?) -> Void in
            if let g = fetched as? Array<Group> {
                completion(g)
            } else {
                completion(nil)
            }
        })
    }
    public func storeUsers(users: Array<User>, completion:(() -> Void)) {
        self.storeInDefault(users, key: "users_index") { () -> Void in
            completion()
        }
    }
    public func fetchUsers(completion:(Array<User>? -> Void)) {
        self.fetchFromDefault("users_index", completion:{(fetched: Array<AnyObject>?) -> Void in
            if let u = fetched as? Array<User> {
                completion (u)
            } else {
                completion(nil)
            }
        })
    }
}

extension Storage {
    public func storeTestData(done:(() -> Void)) {
        self.backgroundDBConnection.asyncReadWriteWithBlock({ (transaction: YapDatabaseReadWriteTransaction) -> Void in
            transaction.setObject("somereallycooltestdata", forKey: "foo", inCollection:"testdata")
        }, completionBlock:done)
    }
    
    public func fetchTestData(done: ((String?) -> Void)) {
        self.backgroundDBConnection.readWithBlock { (transaction: YapDatabaseReadTransaction) -> Void in
            if let d = transaction.objectForKey("foo", inCollection: "testdata") as? String {
                done(d)
            } else {
                done(nil)
            }
        }
    }
}
