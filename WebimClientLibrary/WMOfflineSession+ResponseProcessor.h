//
//  WMSession+ResponseProcessor.h
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 14/06/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import "WMOfflineSession.h"

@class WMChat;
@class WMMessage;

@interface WMOfflineSession (ResponseProcessor)

- (NSDictionary *)processGetHistory:(id)responseObject appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock;
- (WMMessage *)processNewMessage:(NSDictionary *)messageDictionary;
- (WMChat *)processNewAppealWithMessage:(NSDictionary *)messageDictionary;
- (void)processDeleteChat:(WMChat *)chat response:(id)responseObject appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock;
- (void)processMarkAsReadChat:(WMChat *)chat response:(id)responseObject;

@end
