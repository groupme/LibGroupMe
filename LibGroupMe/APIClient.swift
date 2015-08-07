//  APIClient.swift
//  LibGroupMe
//
//  Created by Jon Balbarin on 6/15/15.
//  Copyright © 2015 Jon Balbarin. All rights reserved.
//

import Foundation
import Alamofire

public class APIClient: NSObject {
    /** an NSURLSession-backed Alamofire Manager - tacks on the token, etc */
    private(set) public var manager : Manager!
    private(set) public var backgroundManager : Manager?
    
    /** a GroupMe API auth token for X-Access-Token headers */
    private(set) public var token: String!
    
    /**
        :param: token - token to use for GroupMe API requests (ignored for requests that do not require authentication)
		:param: backgroundSessionIdentifier - uniqe ID for background session (e.g. "group.groupme.shared.extensionsbackgroundsession")
		:param: sharedContainerIdentifier - as defined in project settings "App Groups" (e.g. "group.groupme.shared")
    */

	// TODO change this to accept an optional second  param for `config`
	// or maybe just background session config identifier / shared container identifier
	convenience public init(token: String!) {
		self.init(token:token, backgroundSessionIdentifier:nil, sharedContainerIdentifier:nil)
	}
	required public init(token: String!, backgroundSessionIdentifier: String?, sharedContainerIdentifier: String?) {
        self.token = token
        self.manager = Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

		if let session = backgroundSessionIdentifier as String! {
			let backgroundConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(session)
			if let container = sharedContainerIdentifier as String! {
				backgroundConfig.sharedContainerIdentifier = container
			}
			backgroundConfig.HTTPAdditionalHeaders = ["X-Access-Token": self.token]
			self.backgroundManager = Alamofire.Manager(configuration: backgroundConfig)
		}

    }
    
	private func basicFetch(urlString: String, token:Bool = true, completion: (NSDictionary -> Void)) {

		let headers:[String:String] = (token) ? ["X-Access-Token": self.token] : [:]
		self.manager.request(.GET, urlString, parameters: nil, encoding:.URL, headers:headers)
        .responseJSON(options: .AllowFragments, completionHandler:{(req, resp, json, err) -> Void in
            if let jsonResult = json as? NSDictionary {
                completion(jsonResult)
            } else if err ==  nil {
                // FIXME throw an exception here or something in Swift 2.0
                assert(false) // if we get a non-error response, with unexpected data
            }
        })
    }
    
    /** basic function for asynchronously fetching the first 100 groups from the groups index */
    public func fetchGroups(completion: (NSDictionary -> Void)) {
        self.basicFetch("https://api.groupme.com/v3/groups?per_page=100", completion:completion)
    }
    
    public func fetchDMs(completion: (NSDictionary -> Void)) {
        self.basicFetch("https://api.groupme.com/v3/chats?per_page=100", completion:completion)
    }
    
    /** basic function for asynchronously fetching powerups from the groups index */
    public func fetchPowerups(completion: (NSDictionary -> Void)) {
		self.basicFetch("https://powerup.groupme.com/powerups", token:false, completion:completion)
    }

    /**
    :param: videoData - video data to upload
    :param: completion - closure for passing a status URL to the video's transcode job - check the URL to see whether the video's been transcoded yet 
    :param: progress - closure for passing updates as to how much of the video has been uploaded so far, as a NSProgress object
    */
	public func putVideo(videoData: NSData,  conversationID: String, progress:(NSProgress -> Void), completion: (NSURL? -> Void)) {

		var uploadHeaders:[String:String] = [
			"X-Conversation-Id": conversationID,
			"X-Access-Token": self.token,
		];
		self.manager.upload(Alamofire.Method.POST,  "https://video.groupme.com/transcode", headers:uploadHeaders, multipartFormData:{(formData:MultipartFormData) -> Void in
			formData.appendBodyPart(data: videoData, name: "file", fileName: NSUUID().UUIDString, mimeType:"video/mp4")
		}, encodingMemoryThreshold:((64 * 1024) * 1024), encodingCompletion:{(result: Alamofire.Manager.MultipartFormDataEncodingResult) -> Void in
				switch result {
                case let .Success(request, steamingFromDisk, streamFileURL):
                    request.responseJSON(options: .AllowFragments, completionHandler: { (req, resp, json, err) -> Void in
                        if let j = json as? NSDictionary,
                            let statusURLString = j["status_url"] as? String,
                            let statusURL = NSURL(string: statusURLString) as NSURL!{
                                completion(statusURL)
                        } else {
                            completion(nil)
                        }
                    })
                    .progress(closure:{ (bytesWritten, totalBytesWritten, totalBytesExpected) -> Void in
                        let uploadProgress:NSProgress = NSProgress(totalUnitCount: totalBytesExpected)
                        uploadProgress.completedUnitCount = totalBytesExpected
                        progress(uploadProgress)
                    })
                
                case .Failure:
                    completion(nil)
                
            }
        })
	}



    private func backOffFetch(url:URLRequestConvertible, strategy: BackoffStrategy, completion: ((AnyObject?, NSError?) -> Void)) {
        
        let delay = strategy.nextDelayInterval()
        if delay == -1 {
			completion(nil, NSError(domain: "APIClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "timed out"]))
			return
		}
		println("fetching after \(delay)")
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
			println("fetching")
			self.manager?.request(url).responseJSON(options:.AllowFragments, completionHandler: { (req, resp, json, err) -> Void in
				if let r: NSHTTPURLResponse = resp {
					if r.statusCode == strategy.backoffStatusCode {
                        self.backOffFetch(url, strategy:strategy,  completion:completion)
                        return
					} else if r.statusCode == strategy.finishedStatusCode {
						completion(json, nil)
                        return
					}
                }
				completion(nil, err)
			})
		})
	}

	public func pollVideoStatus(transcodeJobURL: NSURL, completion: ((NSURL?, NSURL?, NSError?) -> Void)) {
		let urlReq = NSMutableURLRequest(URL:transcodeJobURL)
		urlReq.allHTTPHeaderFields = ["X-Access-Token": self.token]

		let strategy = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 201, maxNumberOfTries: 10, multiplier: 1.5)
		
		self.backOffFetch(urlReq, strategy:strategy, completion:{(anyObj, err) -> Void in
			if let d = anyObj as? NSDictionary, v = d["url"] as? String, t = d["thumbnail_url"] as? String {
				if let vURL = NSURL(string: v) as NSURL!, tURL = NSURL(string: t) as NSURL!{
					completion(tURL, vURL, nil)
					return
				}
			}
			completion(nil, nil, err)
		})
	}

	private func userAgent() -> String {
		let bundle:NSBundle = NSBundle(forClass: APIClient.self)
		var model:String = "Unknown"
		var osDesc:String = "Unknown"
		if let locale = NSLocale.currentLocale().objectForKey(NSLocaleIdentifier) as? String,
			infoDict = bundle.infoDictionary as? [String: AnyObject],
			vers = infoDict["CFBundleVersion"] as? String {

				let anOS: NSOperatingSystemVersion = NSProcessInfo().operatingSystemVersion
				let osVersion = String(format:"%d.%d.%d", anOS.majorVersion, anOS.minorVersion, anOS.patchVersion)

				#if os(iOS)
					model =	UIDevice.currentDevice().model
					osDesc = "iOS"
				#else
					model = "Mac"
					osDesc = "OS X"
				#endif

				return String(format:"LibGroupMe/%@ (%@; %@ %@; %@)", vers, model, osDesc, osVersion, locale)
		}

		return "LibGroupMe/0.0"
	}

	public func postMessage(builder: GMPostMessageOperationBuilder, completion:((NSError?) -> Void)) {

		var components = NSURLComponents(string: "https://api.groupme.com")
		components?.path = "/v3/" + builder.path()

		if let url = components?.URL as NSURL!, urlString = url.absoluteString as String! {
			let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
			let dict:NSDictionary = builder.buildPostDictionary()
			println(dict)
			var err:NSError?

			var headers:[String:String] = [
				"X-Access-Token": self.token,
				"User-Agent": self.userAgent(),
			]
			if let paramDict = dict as? [String:AnyObject] {
				self.manager.request(.POST, url.absoluteString!, parameters:paramDict, encoding:.JSON, headers: headers)
					.responseJSON(options:.AllowFragments, completionHandler: { (req, resp, json, err) -> Void in
						println(req.allHTTPHeaderFields)
						println(req)
						println("got it? \(json)")
						completion(err)
				})
			}
		}
	}
}