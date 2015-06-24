//
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
    
    /** a GroupMe API auth token for X-Access-Token headers */
    private(set) public var token: String!
    
    /**
        :param: token - token to use for GroupMe API requests (ignored for requests that do not require authentication)
    */
    required public init(token: String!) {
        self.token = token
        self.manager = Manager()
        self.manager.session.configuration.HTTPAdditionalHeaders = ["X-Access-Token": self.token]
    }
    
    /** basic function for asynchronously fetching the first 100 groups from the groups index */
    public func fetchGroups(completion: (NSDictionary -> Void)) {
        self.manager.request(.GET,  "https://api.groupme.com/v3/groups?per_page=100")
        .responseJSON(options: .AllowFragments, completionHandler:{(req, resp, json, err) -> Void in
            if let jsonResult = json as? NSDictionary {
                completion(jsonResult)
            } else if err ==  nil {
                // FIXME throw an exception here or something in Swift 2.0
                assert(false) // if we get a non-error response, with unexpected data
            }
        })
    }
    
    /** basic function for asynchronously fetching powerups from the groups index */
    public func fetchPowerups(completion: (NSDictionary -> Void)) {
        Alamofire.request(.GET, "https://powerup.groupme.com/powerups")
        .responseJSON(options: .AllowFragments, completionHandler:{(req, resp, json, err) -> Void in
            if let jsonResult = json as? NSDictionary {
                completion(jsonResult)
            } 
        })
        
    }
}