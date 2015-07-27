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
}