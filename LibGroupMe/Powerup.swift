//
//  Powerup.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/15/15.
//  Copyright © 2015 Jon Balbarin. All rights reserved.
//

import Foundation

public class PowerupMeta: NSObject, NSCoding {
    private(set) public var info: NSDictionary!
    required public init(info: NSDictionary!) {
        self.info = info
        // dig into self.info, cache what we need for a keyboard, etc...
    }
    
    // ...and/or funcs for digging into self.info on the fly
    required convenience public init(coder decoder: NSCoder) {
        self.init(info:[:])
        setupWithCoder(coder: decoder)
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        encode(coder)
    }
}

public class Powerup:NSObject, NSCoding {
    
    private(set) public var identifier: String!
    private(set) public var createdAt: NSDate!
    private(set) public var updatedAt: NSDate!
    private(set) public var storeName: String!
    private(set) public var storeDescription: String!
    private(set) public var meta: PowerupMeta!
    
    required public init(info: NSDictionary!) {
        if let identifier = info["id"] as? String {
            self.identifier = identifier
        }
        if let createdAtTimeStamp = info["created_at"] as? NSTimeInterval {
            self.createdAt = NSDate(timeIntervalSince1970: createdAtTimeStamp)
        }
        
        if let updatedAtTimeStamp = info["updated_at"] as? NSTimeInterval {
            self.updatedAt = NSDate(timeIntervalSince1970: updatedAtTimeStamp)
        }
        
        if let name = info["name"] as? String {
            self.storeName = name
        }
        
        if let storeDesc = info["description"] as? String {
            self.storeDescription = storeDesc
        }
        
        if let metaInfo = info["meta"] as? NSDictionary {
            self.meta = PowerupMeta(info:metaInfo)
        }
        
    }
    required convenience public init(coder decoder: NSCoder) {
        self.init(info:[:])
        setupWithCoder(coder: decoder)
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        encode(coder)
    }
}

// extend to do stuff with emoji powerups
extension Powerup {
    public var packID: Int? {
        get {
            if let pID = self.meta.info["pack_id"]  as? Int {
                return pID
            }
            return nil
        }
    }
    
    public func urlForCharAtIndex(index:Int) -> NSURL? {
        return self.stickerFolderURL?.URLByAppendingPathComponent("\(index).png", isDirectory: false)
    }
    
    public var stickerFolderURL: NSURL? {
        get {
            if let stickerVariations = self.meta.info["sticker"] as? Array<NSDictionary> {
                var bestURL: NSURL? = nil
                for variation in stickerVariations {
                    var max = 0
                    if let density = variation["density"] as? Int {
                        if let folderURLString = variation["folder_url"] as? String,
                        folderURL = NSURL(string: folderURLString)
                        where density > max {
                            bestURL = folderURL
                        }
                    
                    }
                }
                return bestURL
            }
            return nil
        }
    }
    public var transliterations: Array<String>? {
        get {
            if let translits =  self.meta.info["transliterations"] as? Array<String> {
                return translits
            }
            return nil
        }
    }
    public var numberOfCharsInPack: Int {
        if let translits = self.transliterations {
            return translits.count
        }
        return 0
    }
}