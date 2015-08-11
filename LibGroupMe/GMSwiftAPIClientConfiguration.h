//
//  GMSwiftAPIClientConfiguration.h
//  LibGroupMe
//
//  Created by Jon Balbarin on 8/11/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
a protocol for configuring APIClient instances, to be passed to `initWithConfig`. a protocol definition should provided
	- access token
	- shared container identifiers / app group idenifiers (for background sessions)
	- base URLs for various API endpoints (e.g. `baseVideoTranscodeURL` is used by `putVideo`, `baseGroupsIndexURL` is used by `fetchGroups`,  etc)
*/

@protocol GMSwiftAPIClientConfigurationProtocol <NSObject>

- (NSURL*) baseAPIv3URL;
- (NSURL*) baseVideoTranscodeURL;

- (NSString*) accessToken;
- (NSString*) backgroundSessionIdentifier;
- (NSString*) sharedContainerIdentifier;

- (instancetype) initWithToken:(NSString*)token backgroundSessionIdentifier:(NSString*)sessionID sharedContainerIdentifier:(NSString*)containerID;

@end

@interface GMSwiftAPIClientConfiguration : NSObject

+ (id<GMSwiftAPIClientConfigurationProtocol>) defaultConfigurationWithToken:(NSString*)token backgroundSessionIdentifier:(NSString*)sessionID sharedContainerIdentifier:(NSString*)containerID;

@end
