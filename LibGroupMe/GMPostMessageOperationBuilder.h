//
//  GMPostMessageOperationBuilder.h
//  GroupMe
//
//  Created by Jon Balbarin on 8/3/15.
//  Copyright (c) 2015 Mindless Dribble, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef enum {
    GMPostMessageOperationRecipientNone = 0,
    GMPostMessageOperationRecipientGroup,
    GMPostMessageOperationRecipientUser,
} GMPostMessageOperationRecipientType;

@class GMAPIClient;

@interface GMPostMessageOperationBuilder : NSObject

@property (nonatomic, readwrite) NSString *sourceGUID;

@property (nonatomic, readwrite) GMPostMessageOperationRecipientType recipientType;
@property (nonatomic, readwrite) NSString *recipientID;

@property (nonatomic, readwrite) NSString *messageText;
@property (nonatomic, readwrite) NSString *imageAttachmentURLString;
@property (nonatomic, readwrite) NSString *imageSourceAttachmentURLString;
@property (nonatomic, readwrite) NSString *videoAttachmentURLString;
@property (nonatomic, readwrite) NSString *videoThumbnailURLString;
@property (nonatomic, readwrite) NSString *locationAttachmentName;
@property (nonatomic, readwrite) CLLocationCoordinate2D locationAttachmentCoordinate;

@property (nonatomic, readwrite) NSString *emojiPlaceholder;
@property (nonatomic, readwrite) NSArray *emojiCharmap;

@property (nonatomic, readwrite) NSDictionary *mentions;

@property (nonatomic, readwrite) NSString *thirdPartyAttachmentType;
@property (nonatomic, readwrite) NSDictionary *thirdPartyAttachmentDictionary;


@property (nonatomic, readwrite, weak) GMAPIClient *httpClient;

-(BOOL) canBuildOperation;
-(NSDictionary*) buildPostDictionary;
-(NSString *)path;


@end
