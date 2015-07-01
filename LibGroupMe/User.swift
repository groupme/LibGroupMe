//
//  User.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/25/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//

import Foundation

public class OtherUser:NSObject, NSCoding {
    private(set) public var avatarURL: NSURL?
    private(set) public var name: NSString!
    private(set) public var userID: NSString!
    
    required public init(info:NSDictionary) {
        if let urlStr = info["avatar_url"] as? String {
            self.avatarURL = NSURL(string: urlStr)
        }
        if let name = info["name"] as? NSString {
            self.name = name
        }
        if let userID = info["id"] as? NSString  {
            self.userID = userID
        }
        super.init()
    }
    required convenience public init(coder decoder: NSCoder) {
        self.init(info:[:])
        setupWithCoder(coder: decoder)
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        encode(coder)
    }
}

public class LastMessage: NSObject, NSCoding {
    private(set) public var messageID: NSString!
    private(set) public var text: NSString!
    
    required public init(info:NSDictionary) {
        if let msgID = info["id"] as? NSString {
            self.messageID = msgID
        }
        if let txt = info["text"] as? NSString {
            self.text = txt
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

public class User: NSObject, NSCoding {
    
    private(set) public var createdAt: NSDate!
    private(set) public var updatedAt: NSDate!
    private(set) public var otherUser: OtherUser!
    private(set) public var lastMessage: LastMessage!
    
    required public init(info:NSDictionary) {
        if let created = info["created_at"] as? NSTimeInterval {
            self.createdAt = NSDate(timeIntervalSince1970: created)
        }
        if let updated = info["updated_at"] as? NSTimeInterval {
            self.updatedAt = NSDate(timeIntervalSince1970: updated)
        }
        if let other = info["other_user"] as? NSDictionary {
            self.otherUser = OtherUser(info: other)
        }
        if let last = info["last_message"] as? NSDictionary {
            self.lastMessage = LastMessage(info: last)
        }
        
        super.init()
    }
    
    required convenience public init(coder decoder: NSCoder) {
        self.init(info:[:])
        setupWithCoder(coder: decoder)
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        encode(coder)
    }
}