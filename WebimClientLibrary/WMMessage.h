//
//  WMMessage.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>


typedef enum {
    WMMessageKindActionRequest,
    WMMessageKindContacts,
    WMMessageKindContactsRequest,
    WMMessageKindFileFromOperator,
    WMMessageKindFileFromVisitor,
    WMMessageKindForOperator,
    WMMessageKindInfo,
    WMMessageKindOperator,
    WMMessageKindOperatorBusy,
    WMMessageKindUnknown,
    WMMessageKindVisitor,
} WMMessageKind;


@class WMBaseSession;
@class WMFileParams;


@interface WMMessage : NSObject

// MARK: - Properties

@property (nonatomic, assign) WMMessageKind kind;

@property (nonatomic, strong) NSString *clientSideId;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) WMFileParams *fileParams;
@property (nonatomic, strong) NSString *rawData;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *uid;

@property (nonatomic, readonly) NSURL *senderAvatarURL;
@property (nonatomic, readonly) NSString *senderName;
@property (nonatomic, readonly) NSString *senderUID;


#pragma mark - private

@property (nonatomic, weak) WMBaseSession *session;
@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *name;

#pragma mark - end private


- (NSString *)filePath;
- (NSURL *)fileURL;
- (NSURL *)imagePreviewURLForKey:(NSString *)key;

- (BOOL)isActionMessage;
- (BOOL)isFileMessage;
- (BOOL)isTextMessage;

@end
