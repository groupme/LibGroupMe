import LibGroupMe
import Quick
import Nimble

class StorageSpec: QuickSpec     {
    override func spec() {
        describe("the storage system") {
            var storage = Storage(name: "StorageSpec")
            
            expect(storage.database).toNot(beNil())
            
            it("should store a list of groups") {
                var dataDict = GroupTestHelper().groupIndex()
                var groups: Array = Array<Group>()
                if let groupInfos = dataDict["response"] as? NSArray {
                    expect(groupInfos.count).to(equal(1))
                    for info in groupInfos {
                        groups.append(Group(info: info as! NSDictionary))
                    }
                    
                } else {
                    fail()
                }
                
                storage.storeGroups(groups) {
                    storage.fetchGroups({(fetched: Array<Group>?) in
                        expect(fetched!.count).to(equal(1))
                    })
                }
            }
        }
    }
}
