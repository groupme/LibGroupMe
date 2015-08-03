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
        self.manager = Manager()
        self.manager.session.configuration.HTTPAdditionalHeaders = ["X-Access-Token": self.token]

		if let session = backgroundSessionIdentifier as String! {
			let backgroundConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(session)
			if let container = sharedContainerIdentifier as String! {
				backgroundConfig.sharedContainerIdentifier = container
			}
			backgroundConfig.HTTPAdditionalHeaders = ["X-Access-Token": self.token]
			self.backgroundManager = Alamofire.Manager(configuration: backgroundConfig)
		}

    }
    
    private func basicFetch(urlString: String, completion: (NSDictionary -> Void)) {
        self.manager.request(.GET, urlString)
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
        self.basicFetch("https://powerup.groupme.com/powerups", completion:completion)
    }

    /**
    :param: videoData - video data to upload
    :param: completion - closure for passing a status URL to the video's transcode job - check the URL to see whether the video's been transcoded yet 
    :param: progress - closure for passing updates as to how much of the video has been uploaded so far, as a NSProgress object
    */
    public func putVideo(videoData: NSData,  progress:(NSProgress -> Void), completion: (NSURL? -> Void)) {

		var manager: Manager!
		if (self.backgroundManager != nil){
			manager = self.backgroundManager
		} else {
			manager = self.manager
		}
        // kinda weird to have to tack on headers this way, but seems like they dont get added automatically, 
        // unlike the standard Manager.request() method
        manager.upload(Alamofire.Method.POST,  "https://video.groupme.com/transcode", headers:manager.session.configuration.HTTPAdditionalHeaders as? [String: String], multipartFormData:{(formData:MultipartFormData) -> Void in
           formData.appendBodyPart(data: videoData, name: "file")
        }, encodingMemoryThreshold: ((64 * 1024) * 1024), encodingCompletion:{(result: Alamofire.Manager.MultipartFormDataEncodingResult) -> Void in
            switch result {
                case let .Success(request, steamingFromDisk, streamFileURL):
                    println(request)
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
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
			var manager: Manager? = nil
			if (self.backgroundManager != nil){
				manager = self.backgroundManager
			} else {
				manager = self.manager
			}
			manager?.request(url).responseJSON(options:.AllowFragments, completionHandler: { (req, resp, json, err) -> Void in
				if let r: NSHTTPURLResponse = resp {
					if r.statusCode == strategy.backoffStatusCode {
                        self.backOffFetch(url, strategy:strategy,  completion:completion)
                        return
					} else if r.statusCode == strategy.finishedStatusCode {
						completion(json, nil)
                        return
					}
                } else {
                    completion(nil, err)
                    return
                }
                
			})
		})
	}

	public func pollVideoStatus(jobID: String, completion: ((NSURL, NSURL) -> Void)) {
        
        var components = NSURLComponents(string: "https://video.groupme.com/status")
        let queryItem = NSURLQueryItem(name: "job", value: jobID)
        components?.queryItems = [queryItem]
        
		if let u = components?.URL as NSURL! {
			let urlReq = NSURLRequest(URL:u)
            
            let strategy = BackoffStrategy(backoffStatusCode: 202, finishedStatusCode: 201, maxNumberOfTries: 10, multiplier: 1.5)
            
            self.backOffFetch(urlReq, strategy:strategy, completion:{(anyObj, err) -> Void in
                if let d = anyObj as? NSDictionary, v = d["url"] as? String, t = d["thumbnail_url"] as? String {
                    if let vURL = NSURL(string: v) as NSURL!, tURL = NSURL(string: t) as NSURL!{
                        completion(tURL, vURL)
                    } else {
                        println("got a backoff or error \(anyObj) \(err)")
                    }
                    
                } else {
                    println("got a backoff or error \(anyObj) \(err)")
                }
			})
		}
	}

}