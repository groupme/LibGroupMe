import LibGroupMe
import Quick
import Nimble

class GroupTest: QuickSpec {
    override func spec() {
        describe("a list of group objects") {
            let path = NSBundle(forClass: NSClassFromString(self.className)!).pathForResource("groups-index", ofType: "json")
            let data = NSData(contentsOfFile: path!)
            var error: NSError?
            var dataDict = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
            
            expect(error).to(beNil())
            expect(dataDict).toNot(beNil())
            
            it("should generate a good list") {
                var groups: Array = Array<Group>()
                if let groupInfos = dataDict["response"] as? NSArray {
                    expect(groupInfos.count).to(equal(1))
                    for info in groupInfos {
                        groups.append(Group(info: info as! NSDictionary))
                    }
                    
                } else {
                    fail()
                }
                
                for group in groups {
                    expect(group.groupName).toNot(beNil())
                    expect(group.groupDescription).toNot(beNil())
                    expect(group.groupAvatarURL).toNot(beNil())
                    expect(group.creatorUserID).toNot(beNil())
                    expect(group.createdAt).toNot(beNil())
                    expect(group.updatedAt).toNot(beNil())
                    expect(group.members).toNot(beNil())
                }
            
        }
    }
}