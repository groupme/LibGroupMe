import LibGroupMe
import Quick
import Nimble

class PowerupTest: QuickSpec {
    override func spec() {
        describe("a list of powerup objects", {
                let path = NSBundle(forClass: NSClassFromString(self.className)!).pathForResource("powerups", ofType: "json")
                let data = NSData(contentsOfFile: path!)
            
//                var dataDict = NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
            var error: NSError?
                var dataDict = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.allZeros, error: &error) as! NSDictionary
            
            
                it("should generate a good list") {
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
