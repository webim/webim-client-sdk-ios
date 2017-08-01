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

@property (nonatomic) BOOL isOffline;
@property (nonatomic) WMChatState state;
@property (nonatomic, strong) NSDate *unreadByOperatorTimestamp;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) WMOperator *chatOperator;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic) BOOL hasUnreadMessages;
@property (nonatomic) BOOL proposeToRateBeforeClose;
@property (nonatomic) BOOL operatorTyping;
@property (nonatomic, strong) NSString *clientSideId;

@end
