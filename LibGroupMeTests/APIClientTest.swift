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

			it("should init a background session manager if needed") {
				let client = APIClient(token:"tokentokentoken")
				expect(client.backgroundManager).to(beNil())

				let backgroundClient = APIClient(token: "sometoken", backgroundSessionIdentifier: "anidentifier", sharedContainerIdentifier: "containerid")
				expect(backgroundClient.backgroundManager).toNot(beNil())
			}
            it("should grab a dictionary from the groups index") {
                OHHTTPStubs.stubRequestsPassingTest({ (req: NSURLRequest) -> Bool in
                    let r:NSURLRequest = req
//                    expect(r.allHTTPHeaderFields).to(equal(["X-Access-Token": "some kinda token"]))
                    expect(r.URL?.absoluteString).to(equal("https://api.groupme.com/v3/groups?per_page=100"))
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

			it("should upload a video and get a transcode id back") {
                OHHTTPStubs.stubRequestsPassingTest({ (req:NSURLRequest) -> Bool in
                    let r:NSURLRequest = req
                    let headers = r.allHTTPHeaderFields;
                    expect(headers?["X-Access-Token"]).toNot(beNil())
                    expect(headers?["X-Access-Token"] as! String!).to(equal("foobarbizbaz"))
                    expect(r.URL?.absoluteString).to(equal("https://video.groupme.com/transcode"))
                    return true
                }, withStubResponse: { (urlReq) -> OHHTTPStubsResponse in
                    let respDict = ["status_url": "https://video.groupme.com/status?job=23074650-41EE-4507-8D9E-11E47368BEF8"];
                    
                    
                    return OHHTTPStubsResponse(JSONObject: respDict, statusCode: 200, headers: nil)
                })
                
                let client = APIClient(token: "foobarbizbaz")
                
                let testData = "somefakevideodata".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                var statusURL: NSURL? = nil;
                client.putVideo(testData!, progress:{(progress: NSProgress) in
                    println("got some progress \(progress)")
                }, completion:{(s:NSURL?) in
                    println("got a url \(statusURL)")
                    statusURL = s
                })
                expect(statusURL).toEventuallyNot(beNil())
			}
        })
    }
}


