//
//  WMBaseSession.h
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 09/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    WMSessionErrorUnknown,
    WMSessionErrorReinitRequired,
    WMSessionErrorServerNotReady,
    WMSessionErrorAccountBlocked,
    WMSessionErrorVisitorBanned,
    WMSessionErrorNetworkError,
    WMSessionErrorVisitorNotSet,// Ex-WMSessionErrorNotAnError
    WMSessionErrorEmptyMessageText,// Ex-WMSessionErrorChatText
    WMSessionErrorChatNotFound,// To be removed
    WMSessionErrorNotConfigured,// To be removed
    WMSessionErrorAttachmentTypeNotAllowed,
    WMSessionErrorAttachmentSizeExceeded,
    WMSessionErrorMessageSizeExceeded,
    WMSessionErrorResponseDataError,
    WMSessionErrorChatCountLimitExceeded,
} WMSessionError;

typedef enum {
    WMChatAttachmentImageJPEG,
    WMChatAttachmentImagePNG,
} WMChatAttachmentImageType;

typedef NS_ENUM(NSInteger, WMOperatorRate) {
    WMOperatorRateOneStar = -2,
    WMOperatorRateTwoStars = -1,
    WMOperatorRateThreeStars =  0,
    WMOperatorRateFourStars =  1,
    WMOperatorRateFiveStars =  2,
};


@class WMMessage;


extern NSString *const WMWebimErrorDomain;


@interface WMBaseSession : NSObject

@property (nonatomic, strong) NSString *location;
@property (nonatomic, readonly, strong) NSString *accountName;


// MARK: Initialization
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location;


- (NSString *)host;
- (void)clearCachedUserData;

- (NSURL *)attachmentURLForMessage:(WMMessage *)message;

- (void)downloadImageForMessage:(WMMessage *)message
                     completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block;

- (void)downloadImagePreviewForMessage:(WMMessage *)message
                                   key:(NSString *)key
                            completion:(void (^)(BOOL successful, UIImage *image, NSError *))block;

// MARK: Private methods
- (void)enqueueHTTPRequestOperation:(id)operation;

@end
