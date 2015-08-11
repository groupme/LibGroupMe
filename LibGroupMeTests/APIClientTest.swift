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


			let config = GMSwiftAPIClientConfiguration.defaultConfigurationWithToken("foo", backgroundSessionIdentifier: nil, sharedContainerIdentifier: nil)
			let client = APIClient(config: config as protocol<GMSwiftAPIClientConfigurationProtocol>)

			it("should init a background session manager if needed") {
				expect(client.backgroundManager).to(beNil())

				let backgroundConfig = GMSwiftAPIClientConfiguration.defaultConfigurationWithToken("foo", backgroundSessionIdentifier: "bar", sharedContainerIdentifier: "baz")
				let backgroundClient = APIClient(config: backgroundConfig as protocol<GMSwiftAPIClientConfigurationProtocol>)
				expect(backgroundClient.backgroundManager).toNot(beNil())
			}
			it("should grab a dictionary from the groups index") {
				OHHTTPStubs.stubRequestsPassingTest({ (req: NSURLRequest) -> Bool in
					let r:NSURLRequest = req
					//                    expect(r.allHTTPHeaderFields).to(equal(["X-Access-Token": "some kinda token"]))
					let headers = r.allHTTPHeaderFields;
					expect(headers?["X-Access-Token"]).toNot(beNil())
					expect(r.URL?.absoluteString).to(equal("https://api.groupme.com/v3/groups?per_page=100"))
					return true
					}, withStubResponse: { (urlReq) -> OHHTTPStubsResponse in
						return OHHTTPStubsResponse(data: "{\"foo\": \"bar\", \"biz\": 111}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)!, statusCode: 200, headers: nil)
				})

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


