import LibGroupMe
import Quick
import Nimble
import OHHTTPStubs

class APIClientSpec: QuickSpec {
    override func spec() {
        describe("the api client", {
            afterEach({ () -> () in
                OHHTTPStubs.removeAllStubs()
            })
            
            it("should grab a dictionary from the groups index") {
                OHHTTPStubs.stubRequestsPassingTest({ (req: NSURLRequest) -> Bool in
                    let r:NSURLRequest = req
//                    expect(r.allHTTPHeaderFields).to(equal(["X-Access-Token": "some kinda token"]))
                    expect(r.URL?.absoluteString).to(equal("https://api.groupme.com/v3/groups"))
                    return true
                    }, withStubResponse: { (urlReq) -> OHHTTPStubsResponse in
                        return OHHTTPStubsResponse(data: "{\"foo\": \"bar\", \"biz\": 111}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)!, statusCode: 200, headers: nil)
                })
                
                let client = APIClient(token: "some kinda token")
                var r: NSDictionary? = nil
                
                client.fetchGroups({ (json) -> (Void) in
                    r = json
                })
                expect(r).toEventually(equal(["foo":"bar", "biz": 111]))
            }
            it("should grab a dictionary from the powerups service") {
                OHHTTPStubs.stubRequestsPassingTest({ (req: NSURLRequest) -> Bool in
                    let r:NSURLRequest = req
                    let headers = r.allHTTPHeaderFields;
                    expect(headers?["X-Access-Token"]).to(beNil())
                    expect(r.URL?.absoluteString).to(equal("https://powerup.groupme.com/powerups"))
                    return true
                }, withStubResponse: { (urlReq) -> OHHTTPStubsResponse in
                    let fixture = OHPathForFile("powerups.json", self.dynamicType)
                    return OHHTTPStubsResponse(fileAtPath: fixture!, statusCode: 200, headers: ["Content-Type":"application/json"])
                })
                
                let client = APIClient(token:"foo")// doesnt matter because this request wont use it anyway
                var r: NSDictionary? = nil
                client.fetchPowerups({(json:NSDictionary?) in
                    r = json
                })
                expect(r).toEventuallyNot(beNil())
                expect(r?.allKeys).toEventually(contain("powerups"))
            }
        })
    }
}


