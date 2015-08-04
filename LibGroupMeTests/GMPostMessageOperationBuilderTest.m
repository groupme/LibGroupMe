//
//  GMPostMessageOperationBuilderTest.m
//  LibGroupMe
//
//  Created by Jon Balbarin on 8/4/15.
//  Copyright (c) 2015 Jon Balbarin. All rights reserved.
//

@import Quick;
@import Nimble;
#import "GMPostMessageOperationBuilder.h"

QuickSpecBegin(GMPostMessageOperationBuilderTest)
context(@"given typical data from the video service", ^{
    describe(@"and a group ID", ^{
        GMPostMessageOperationBuilder *builder = [[GMPostMessageOperationBuilder alloc] init];
        builder.sourceGUID = @"FD4FA616-6BE8-4EDF-B88A-561B3B440126";
        builder.recipientID = @"12345";
        builder.recipientType = GMPostMessageOperationRecipientGroup;
        builder.messageText = @"foobar biz baz";
        builder.videoThumbnailURLString = @"https://example.com/thing.jpeg";
        builder.videoAttachmentURLString = @"https://example.com/thing.mp4";
        it(@"should describe the correct payload and path for posting to the group messages endpoint", ^{
            NSDictionary *expectedPostDict =
            @{
              @"message": @{
                      @"attachments":
                          @[
                              @{
                                  @"preview_url": @"https://example.com/thing.jpeg",
                                  @"type": @"video",
                                  @"url": @"https://example.com/thing.mp4",
                                  },
                              ],
                      @"source_guid": @"FD4FA616-6BE8-4EDF-B88A-561B3B440126",
                      @"text": @"foobar biz baz",
                      },
              };

            NSDictionary *postDict = [builder buildPostDictionary];
            expect(postDict).to(equal(expectedPostDict));
            expect(builder.path).to(equal(@"groups/12345/messages"));
        });
    });
    describe(@"and a user ID", ^{
        GMPostMessageOperationBuilder *builder = [[GMPostMessageOperationBuilder alloc] init];
        builder.sourceGUID = @"FD4FA616-6BE8-4EDF-B88A-561B3B440126";
        builder.recipientID = @"12345";
        builder.recipientType = GMPostMessageOperationRecipientUser;
        builder.messageText = @"foobar biz baz";
        builder.videoThumbnailURLString = @"https://example.com/thing.jpeg";
        builder.videoAttachmentURLString = @"https://example.com/thing.mp4";
        it(@"should post the right payload to the DMs endpoint", ^{
            NSDictionary *expectedPostDict =
            @{
              @"direct_message": @{
                      @"attachments": @[
                              @{
                                  @"preview_url": @"https://example.com/thing.jpeg",
                                  @"type": @"video",
                                  @"url": @"https://example.com/thing.mp4",
                                  },
                              ],
                      @"recipient_id": @"12345",
                      @"source_guid": @"FD4FA616-6BE8-4EDF-B88A-561B3B440126",
                      @"text": @"foobar biz baz",
                      },
              };

            NSDictionary *postDict = [builder buildPostDictionary];
            expect(builder.path).to(equal(@"direct_messages"));
            expect(postDict).to(equal(expectedPostDict));
        });
    });
});
QuickSpecEnd


