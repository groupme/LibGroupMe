import LibGroupMe
import Quick
import Nimble

class UserTestHelper: NSObject {
    func dmIndex() -> NSDictionary {
        let path = NSBundle(forClass: NSClassFromString(self.className)!).pathForResource("dms-index", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        var error: NSError?
        var dataDict = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
        
        expect(error).to(beNil())
        expect(dataDict).toNot(beNil())
        return dataDict
    }
}
class UserTest: QuickSpec {
    override func spec() {
        describe("a list of dm-s") {
            it("should generate a list of serializable objects") {
                var dict = UserTestHelper().dmIndex()
                
                var dms: Array<User> = Array<User>()
                if let dmInfos = dict["response"] as? NSArray {
                    expect(dmInfos.count).to(equal(1))
                    for info in dmInfos {
                        dms.append(User(info: info as! NSDictionary))
                    }
                } else {
                    fail()
                }
                expect(dms.count).to(equal(1))
                
                for d in dms {
                    expect(d.createdAt).toNot(beNil())
                    expect(d.updatedAt).toNot(beNil())
                    expect(d.otherUser).toNot(beNil())
                    expect(d.otherUser.name).toNot(beNil())
                    expect(d.otherUser.userID).toNot(beNil())
                    
                    expect(d.lastMessage).toNot(beNil())
                    expect(d.lastMessage.text).toNot(beNil())
                    expect(d.lastMessage.messageID).toNot(beNil())
                }
            }
        }
    }
}