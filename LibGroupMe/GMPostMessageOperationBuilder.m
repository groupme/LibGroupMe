//
//  GMPostMessageOperationBuilder.m
//  GroupMe
//
//  Created by Jon Balbarin on 8/3/15.
//  Copyright (c) 2015 Mindless Dribble, Inc. All rights reserved.
//

#import "GMPostMessageOperationBuilder.h"

@implementation GMPostMessageOperationBuilder


-(BOOL) canBuildOperation {
    return (self.httpClient && self.recipientID && self.recipientType);
}

-(NSDictionary*) buildPostDictionary  {
    if(self.recipientType == GMPostMessageOperationRecipientNone) {
        return nil;
    }
    NSString *root = nil;
    root = (self.recipientType == GMPostMessageOperationRecipientGroup) ? @"message" : root;
    root = (self.recipientType == GMPostMessageOperationRecipientUser) ? @"direct_message" : root;
    NSArray *attachments = [self buildAttachmentArray];
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{@"text": self.messageText, @"source_guid": self.sourceGUID, @"attachments": attachments}];
    if(self.recipientType == GMPostMessageOperationRecipientUser) {
        [payload setObject:self.recipientID forKey:@"recipient_id"];
    }
    if (root != nil)
        return @{root: payload};
    else
        return nil;
}


-(NSString *)path {
    if(self.recipientType == GMPostMessageOperationRecipientGroup){
        return [NSString stringWithFormat:@"groups/%@/messages", self.recipientID];
    } else if (self.recipientType == GMPostMessageOperationRecipientUser){
        return  @"direct_messages";
    }
    return nil;
}

#pragma mark private


-(NSArray*) buildAttachmentArray {
    NSMutableArray *attachments = [NSMutableArray array];
    if(self.emojiPlaceholder && self.emojiCharmap) {
        // trim emojiCharmap
        NSMutableArray *cleanCharmap = [NSMutableArray arrayWithCapacity:[self.emojiCharmap count]];
        for(NSObject *entry in self.emojiCharmap) {
            if([entry isKindOfClass:[NSArray class]]) {
                NSArray *entryArray = (NSArray*) entry;
                if([entryArray count] >= 2){
                    [cleanCharmap addObject:@[entryArray[0], entryArray[1]]];
                }
            }
        }
        [attachments addObject:@{@"type": @"emoji", @"placeholder": self.emojiPlaceholder, @"charmap": cleanCharmap}];
    }
    if(self.imageAttachmentURLString && self.imageSourceAttachmentURLString) {
        [attachments addObject:@{@"type": @"image", @"url": self.imageAttachmentURLString, @"source_url":self.imageSourceAttachmentURLString}];
    } else if (self.imageAttachmentURLString) {
        [attachments addObject:@{@"type": @"image", @"url": self.imageAttachmentURLString}];
    }
    if(self.videoAttachmentURLString && self.videoThumbnailURLString){
        [attachments addObject:@{@"type": @"video", @"url": self.videoAttachmentURLString, @"preview_url": self.videoThumbnailURLString}];
    }
    if(self.locationAttachmentName && CLLocationCoordinate2DIsValid((self.locationAttachmentCoordinate)))  {
        NSString *latString = [NSString stringWithFormat:@"%f", self.locationAttachmentCoordinate.latitude];
        NSString *lngString = [NSString stringWithFormat:@"%f", self.locationAttachmentCoordinate.longitude];
        [attachments addObject:@{@"type": @"location", @"lat": latString, @"lng": lngString, @"name": self.
                                 locationAttachmentName}];
    }
    if(self.mentions != nil) {
        [attachments addObject: @{@"type":@"mentions", @"user_ids":_mentions[@"user_ids"], @"loci":_mentions[@"loci"]}];
    }
    
    if(self.thirdPartyAttachmentDictionary && self.thirdPartyAttachmentType) {
        [attachments addObject:@{@"type": @"thirdparty", @"name": self.thirdPartyAttachmentType, @"data": self.thirdPartyAttachmentDictionary}];
    }
    
    return [NSArray arrayWithArray:attachments];
}

@end
