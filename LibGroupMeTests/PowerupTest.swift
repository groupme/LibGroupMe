import LibGroupMe
import Quick
import Nimble


class PowerupTestHelper: NSObject {
    func powerupIndex() -> NSDictionary {
        let path = NSBundle(forClass: NSClassFromString(self.className)!).pathForResource("powerups", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        
        var error: NSError?
        var dataDict = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
        
        expect(error).to(beNil())
        return dataDict
    }
    func powerupFixtures() -> Array<Powerup> {
        var dataDict = PowerupTestHelper().powerupIndex()
        expect(dataDict).toNot(beNil())
        expect(dataDict.allKeys.count).to(beGreaterThan(0))
        var powerups: Array = Array<Powerup>()
        if let powerupInfos = dataDict["powerups"] as? NSArray {
            expect(powerupInfos.count).to(equal(17))
            for p in powerupInfos {
                powerups.append(Powerup(info: p as? NSDictionary))
            }
        } else {
            fail()
        }
        
        expect(powerups.count).to(equal(17))
        return powerups
    }
}

class PowerupTest: QuickSpec {
    override func spec() {
        describe("a list of powerup objects", {
            it("should generate a good list") {
                
                let powerups = PowerupTestHelper().powerupFixtures()
                expect(powerups.count).to(equal(17))
                
                for powerup in powerups {
                    expect(powerup.identifier).toNot(beNil())
                    expect(powerup.createdAt).toNot(beNil())
                    expect(powerup.updatedAt).toNot(beNil())
                    expect(powerup.storeName).toNot(beNil())
                    expect(powerup.storeDescription).toNot(beNil())
                    expect(powerup.meta).toNot(beNil())
                }
                
            }
            
        })
    }
}
