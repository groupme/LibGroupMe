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
    private(set) public var manager : Manager!
    private(set) public var token: String!
    required public init(token: String!) {
        self.token = token
        self.manager = Manager()
        self.manager.session.configuration.HTTPAdditionalHeaders = ["X-Access-Token": self.token]
    }
    
    // fetches Groups Index
    public func fetchGroups(completion: (NSDictionary -> Void)) {
        self.manager.request(.GET,  "https://api.groupme.com/v3/groups?per_page=100")
        .responseJSON(options: .AllowFragments, completionHandler:{(req, resp, json, err) -> Void in
            if let jsonResult = json as? NSDictionary {
                completion(jsonResult)
            } else {
                assert(false)
            }
        })
    }
    
    public func fetchPowerups(completion: (NSDictionary -> Void)) {
        Alamofire.request(.GET, "https://powerup.groupme.com/powerups")
        .responseJSON(options: .AllowFragments, completionHandler:{(req, resp, json, err) -> Void in
            if let jsonResult = json as? NSDictionary {
                completion(jsonResult)
            } else {
                assert(false)
            }
        })
        
    }
}