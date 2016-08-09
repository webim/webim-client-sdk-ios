//
//  WMChatDataViewController.h
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatBaseViewController.h"

#import "WMMessage.h"
#import "WMChat.h"

@protocol WMChatDataSourceProtocol <NSObject>
@optional
- (WMChat *)chatDataSourceCurrentChat;
- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block;
@end

@interface WMChatDataViewController : WMChatBaseViewController

@property (strong, nonatomic) NSMutableArray *messagesDataSource;

@property (nonatomic, strong) NSDictionary *timestampMessageDictionary;

@property (nonatomic, strong) NSDictionary *operators;
@property (nonatomic, strong) JSQMessagesBubbleImage *operatorBubbleImage;

@property (nonatomic, strong) NSString *systemID;
@property (nonatomic, strong) NSString *systemName;
@property (nonatomic, strong) JSQMessagesBubbleImage *systemBubbleImage;
@property (nonatomic, strong) JSQMessagesAvatarImage *systemAvararImage;

@property (nonatomic, strong) JSQMessagesBubbleImage *senderBubbleImage;
@property (nonatomic, strong) JSQMessagesAvatarImage *senderAvatarImage;

- (void)reloadBubbleTableView;

@end
