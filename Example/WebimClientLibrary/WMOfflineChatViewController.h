//
//  WMOfflineChatViewController.h
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatDataViewController.h"

@class WMChat;

@interface WMOfflineChatViewController : WMChatDataViewController

@property (nonatomic, strong) WMChat *chat;

@end
