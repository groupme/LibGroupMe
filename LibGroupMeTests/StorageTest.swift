import LibGroupMe
import Quick
import Nimble

class StorageSpec: QuickSpec     {
    override func spec() {
        describe("the storage system") {
            var storage: Storage? = nil
            storage = Storage(name: "StorageSpec")
            
            it("should store a list of groups") {
                var dataDict = GroupTestHelper().groupIndex()
                var groups: Array = Array<Group>()
                if let groupInfos = dataDict["response"] as? NSArray {
                    expect(groupInfos.count).to(equal(9))
                    for info in groupInfos {
                        groups.append(Group(info: info as! NSDictionary))
                    }
                    
                } else {
                    fail()
                }
                
                var fetchedGroups: Array<Group>? = []
                storage!.storeGroups(groups) {
                    storage!.fetchGroups({(fetched: Array<Group>?) in
                        fetchedGroups = fetched;
                    })
                }
                expect(fetchedGroups!.count).toEventually(equal(9))
            }
            it("should store a list of powerups") {
                var powerups = PowerupTestHelper().powerupFixtures()
                expect(powerups.count).to(beGreaterThan(1))
                var fetchedPowerups: Array<Powerup>? = []
                storage!.storePowerups(powerups, completion: { () -> Void in
                    storage!.fetchPowerups({(fetched: Array<Powerup>?) in
                        fetchedPowerups = fetched
                    })
                })
                expect(fetchedPowerups!.count).toEventually(equal(powerups.count))
            }
        }
    }
}
