//
//  GMSwiftAPIClientConfiguration.m
//  LibGroupMe
//
//  Created by Jon Balbarin on 8/11/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//

#import "GMSwiftAPIClientConfiguration.h"

/**
 a private class that provides the default production configuration for an `APIClient`
 */
@interface GMDefaultSwiftAPIClientConfiguration : NSObject<GMSwiftAPIClientConfigurationProtocol>
@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSString *backgroundSessionIdentifier;
@property (nonatomic) NSString *sharedContainerIdentifier;
@end

@implementation GMDefaultSwiftAPIClientConfiguration

- (instancetype)initWithToken:(NSString *)token backgroundSessionIdentifier:(nullable NSString *)sessionID sharedContainerIdentifier:(nullable NSString *)containerID {
	self = [super init];

	if(self){
		self.accessToken = token;
		self.backgroundSessionIdentifier = sessionID;
		self.sharedContainerIdentifier = containerID;
	}
	return self;
}

- (NSURL *)baseVideoTranscodeURL {
	return [NSURL URLWithString:@"https://video.groupme.com/transcode"];
}

- (NSURL *)baseAPIv3URL {
	return [NSURL URLWithString:@"https://api.groupme.com/v3"];
}

@end


@implementation GMSwiftAPIClientConfiguration

+(id<GMSwiftAPIClientConfigurationProtocol>)defaultConfigurationWithToken:(NSString *)token
										backgroundSessionIdentifier:(NSString *)sessionID
										  sharedContainerIdentifier:(NSString *)containerID {

	return [[GMDefaultSwiftAPIClientConfiguration alloc] initWithToken:token backgroundSessionIdentifier:sessionID sharedContainerIdentifier:containerID];

}

@end
