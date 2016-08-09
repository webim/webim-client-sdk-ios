//
//  WMMessage+Private.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import "WMMessage.h"

@class WMBaseSession;

@interface WMMessage (Private) <NSCoding>

- (WMMessage *)initWithObject:(NSDictionary *)object forSession:(WMBaseSession *)session;

@end

void import_Message_Private();
