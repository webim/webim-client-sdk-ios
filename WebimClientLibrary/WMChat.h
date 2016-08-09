//
//  WMChat.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMOperator;

typedef enum {
    WMChatStateUnknown,
    WMChatStateQueue,
    WMChatStateChatting,
    WMChatStateClosed,
    WMChatStateClosedByVisitor,
    WMChatStateClosedByOperator,
    WMChatStateInvitation,
} WMChatState;

@interface WMChat : NSObject

@property (nonatomic, assign) BOOL isOffline;
@property (nonatomic, assign) WMChatState state;
@property (nonatomic, strong) NSDate *unreadByOperatorTimestamp;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) WMOperator *chatOperator;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) BOOL hasUnreadMessages;
@property (nonatomic, assign) BOOL proposeToRateBeforeClose;
@property (nonatomic, assign) BOOL operatorTyping;
@property (nonatomic, strong) NSString *clientSideId;

@end
