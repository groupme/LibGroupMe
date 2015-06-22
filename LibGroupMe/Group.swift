import Foundation

public class Member: NSObject, NSCoding {
    private(set) public var userID: String!
    private(set) public var nickname: String!
    private(set) public var avatarURL: NSURL?
    
    required public init(info: NSDictionary) {
        if let user = info["user_id"] as? String {
            self.userID = user
        }
        if let nick = info["nickname"] as? String {
            self.nickname = nick
        }
        if let avatarURLStr = info["image_url"] as? String {
            self.avatarURL = NSURL(string: avatarURLStr)
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

public class MessagesOverview: NSObject, NSCoding {
    private(set) public var messageCount: NSNumber!
    private(set) public var lastMessageID: String!
    private(set) public var lastMessageCreatedAt: NSDate!
    private(set) public var preview: MessagePreview!
    
    required public init(info: NSDictionary) {
        if let c = info["count"] as? NSNumber {
            self.messageCount = c
        }
        if let lastMsg = info["last_message_id"] as? String {
            self.lastMessageID = lastMsg
        }
        if let lastMessageCreatedAt = info["last_message_created_at"] as? NSTimeInterval {
            self.lastMessageCreatedAt = NSDate(timeIntervalSince1970: lastMessageCreatedAt)
        }
        
        if let preview = info["preview"] as? NSDictionary{
            self.preview = MessagePreview(info: preview)
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

public class MessagePreview: NSObject, NSCoding {
    private(set) public var nickname: String!
    private(set) public var text: String!
    private(set) public var avatarURL: NSURL!
    
    required public init(info:NSDictionary) {
        if let nick = info["nickname"] as? String {
            self.nickname = nick
        }
        if let text = info["text"] as? String {
            self.text = text
        }
        if let urlString = info["image_url"] as? String {
            self.avatarURL = NSURL(string: urlString)
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

public class Group: NSObject, NSCoding {
    
    private(set) public var identifier: String!
    private(set) public var groupName: String!
    private(set) public var groupDescription: String!
    private(set) public var groupAvatarURL: NSURL?
    private(set) public var creatorUserID: String!
    private(set) public var createdAt: NSDate!
    private(set) public var updatedAt: NSDate!
    private(set) public var members: Array<Member>!
    
    private(set) public var overview: MessagesOverview!
 
    required public init(info: NSDictionary){
        if let identifier = info["id"] as? String {
            self.identifier = identifier
        }
        if let name = info["name"] as? String {
            self.groupName = name
        }
        if let desc = info["description"] as? String {
            self.groupDescription = desc
        }
        if let avatarURLStr = info["image_url"] as? String {
            self.groupAvatarURL = NSURL(string: avatarURLStr)
        }
        if let creator = info["creator_user_id"] as? String {
            self.creatorUserID = creator
        }
        if let created = info["created_at"] as? NSTimeInterval {
            self.createdAt = NSDate(timeIntervalSince1970: created)
        }
        if let updated = info["updated_at"] as? NSTimeInterval {
            self.updatedAt = NSDate(timeIntervalSince1970: updated)
        }
        if let overview = info["messages"] as? NSDictionary {
            self.overview = MessagesOverview(info: overview)
        }
        self.members = []
        if let memberList = info["members"] as? Array<NSDictionary> {
            for dict in memberList {
                var member = Member(info: dict)
                self.members.append(member)
            }
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