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
    
    public func storeTestData(done:(() -> Void)) {
        self.backgroundDBConnection.asyncReadWriteWithBlock({ (transaction: YapDatabaseReadWriteTransaction) -> Void in
            transaction.setObject("somereallycooltestdata", forKey: "foo", inCollection:"testdata")
        }, completionBlock:done)
    }
    
    public func fetchTestData(done: ((String?) -> Void)) {
//        self.backgroundDBConnection.asyncReadWithBlock { (transaction: YapDatabaseReadTransaction) -> Void in
//            return transaction.objectForKey("foo", inCollection: "testData")
//        }, completionBlock:done(
        
        self.backgroundDBConnection.readWithBlock { (transaction: YapDatabaseReadTransaction) -> Void in
            if let d = transaction.objectForKey("foo", inCollection: "testdata") as? String {
                done(d)
            } else {
                done(nil)
            }
        }
    }
    
}