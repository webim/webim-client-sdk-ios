//
//  WMChat+Private.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChat.h"

@class WMBaseSession;

@interface WMChat (Private) <NSCoding>

- (void)initWithObject:(NSDictionary *)object forSession:(WMBaseSession *)session;
- (WMChatState)chatStateFromString:(NSString *)stateString;

- (void)copyValues:(WMChat *)fromObject;

@end

void import_Chat_Private();
