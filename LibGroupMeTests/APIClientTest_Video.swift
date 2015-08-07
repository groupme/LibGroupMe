import LibGroupMe
import Quick
import Nimble
import OHHTTPStubs

class APIClient_VideoSpec: QuickSpec {
//    let errorResponse = OHHTTPStubsResponse() // something's gone wrong
//    errorResponse.statusCode = 500
//
//    let oldResponse = OHHTTPStubsResponse() // status jobs only last for so long, before they expire
//    oldResponse.statusCode = 404

    let expectedStatusURLString = "https://video.groupme.com/status?job=23074650-41EE-4507-8D9E-11E47368BEF8"
    private func doneResponse() -> OHHTTPStubsResponse {
        let doneJSON = [
            "status": "complete",
            "url": "https://example.com/something.mp4",
            "thumbnail_url": "https://example.com/something.jpeg",
        ]
        let doneResponse = OHHTTPStubsResponse(JSONObject: doneJSON, statusCode: 201, headers: nil) // all good
        return doneResponse
    }
    
    
    private func backoffResponse() -> OHHTTPStubsResponse{
        let backoffResponse = OHHTTPStubsResponse() // back off with 202 /Accepted
        backoffResponse.statusCode = 202
        return backoffResponse
    }
    
    override func spec() {
        describe("uploading video data") {
			it("should upload a video and get a transcode id back, and poll it until it gets a good result") {
				let expectedStatusURLString = "https://video.groupme.com/status?job=23074650-41EE-4507-8D9E-11E47368BEF8"
				// stub the transcode response
                OHHTTPStubs.stubRequestsPassingTest({ (req:NSURLRequest) -> Bool in
					let isPostToTranscode = (req.HTTPMethod == "POST") && (req.URL!.absoluteString == "https://video.groupme.com/transcode")
					if isPostToTranscode {
						let r:NSURLRequest = req
						let headers = r.allHTTPHeaderFields;
						expect(headers?["X-Access-Token"]).toNot(beNil())
						expect(headers?["X-Access-Token"] as! String!).to(equal("foobarbizbaz"))
						expect(headers?["X-Conversation-Id"]).toNot(beNil())
						expect(headers?["X-Conversation-Id"] as! String!).to(equal("4567"))
						expect(r.URL?.absoluteString).to(equal("https://video.groupme.com/transcode"))
						return true
					}
                    fail()
					return false
                }, withStubResponse: { (urlReq) -> OHHTTPStubsResponse in
                    let respDict = ["status_url": expectedStatusURLString];
                    return OHHTTPStubsResponse(JSONObject: respDict, statusCode: 200, headers: nil)
                })

                let client = APIClient(token: "foobarbizbaz")
                
                let testData = "somefakevideodata".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                
                var statusURL: NSURL? = nil;
				client.putVideo(testData!, conversationID:"4567", progress:{(progress: NSProgress) in
                    println("got some progress \(progress)")
                }, completion:{(s:NSURL?) in
                    println("got a url \(statusURL)")
                    statusURL = s
                })
                expect(statusURL?.absoluteString).toEventually(equal(expectedStatusURLString))
			}
        }
        
        
        describe("waiting for transcode and getting success first try", { () -> Void in
            
            afterEach({ () -> () in
                OHHTTPStubs.removeAllStubs()
            })

            
            it("should ping the video status endpoint and get a status, url, and thumb url") {
                // stub a 201 on the first try
                OHHTTPStubs.stubRequestsPassingTest({ (req) -> Bool in
                    if req.HTTPMethod == "GET" && req.URL!.absoluteString == self.expectedStatusURLString {
                        return true
                    }
                    fail()
                    return false
                }, withStubResponse: { (req) -> OHHTTPStubsResponse in
                    return self.doneResponse()
                });
                
                let client = APIClient(token:"foo")
                
                var vURL: NSURL? = nil
                var tURL: NSURL? = nil

				let transcodeJobURL = NSURL(string: self.expectedStatusURLString, relativeToURL: nil) as NSURL!
				client.pollVideoStatus(transcodeJobURL, completion: {(thumbURL:NSURL?, vidURL:NSURL?, err:NSError?) -> Void in
                    vURL = vidURL
                    tURL = thumbURL
					expect(err).to(beNil());
                })
                // first poll fetch is delayed, so wait more than the default 1s
                expect(vURL).toEventuallyNot(beNil(), timeout: 1.2, pollInterval: 0.01)
                expect(tURL).toEventuallyNot(beNil(), timeout: 1.2, pollInterval: 0.01)
                
            }
        })
        describe("waiting for transcode and falling back", { () -> Void in
            
            afterEach({ () -> () in
                OHHTTPStubs.removeAllStubs()
            })

            it("should handle backoff until eventually getting a status, url, and thumb url") {
                let numberOfBackOffs = 3
                var currentBackoff = 0
                // stub a couple of 202-s before succeeding with a 201
                OHHTTPStubs.stubRequestsPassingTest({ (req) -> Bool in
                    if req.HTTPMethod == "GET" && req.URL!.absoluteString == self.expectedStatusURLString {
                        return true
                    }
                    fail()
                    return false
                    }, withStubResponse: { (req) -> OHHTTPStubsResponse in
                        if currentBackoff < numberOfBackOffs {
                            currentBackoff++
                            return self.backoffResponse()
                        } else {
                            return self.doneResponse()
                        }
                        
                });
                
                let client = APIClient(token:"foo")
                
                var vURL: NSURL? = nil
                var tURL: NSURL? = nil
				let transcodeJobURL = NSURL(string: self.expectedStatusURLString, relativeToURL: nil) as NSURL!
				client.pollVideoStatus(transcodeJobURL, completion: {(thumbURL:NSURL?, vidURL:NSURL?, err:NSError?) -> Void in
                    vURL = vidURL
                    tURL = thumbURL
					expect(err).to(beNil());
                })
                // first poll fetch is delayed, so wait more than the default 1s
                expect(vURL).toEventuallyNot(beNil(), timeout: 8.2, pollInterval: 0.01)
                expect(tURL).toEventuallyNot(beNil(), timeout: 8.2, pollInterval: 0.01)
            }
        })
    }
}
