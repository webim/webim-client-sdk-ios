//
//  WMOfflineChatViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMOfflineChatViewController.h"

#import "WebimController.h"

@interface WMOfflineChatViewController () <WMChatDataSourceProtocol>

@end

@implementation WMOfflineChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputToolbar.hidden = (self.chat != nil) && !self.chat.isOffline;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(webimNotificationsDidReceiveUpdateNotification:)
                               name:WebimNotifications.didReceiveUpdate
                             object:nil];
    
    [self reloadBubbleTableView];
    [self finishReceivingMessageAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadBubbleTableView {
    [super reloadBubbleTableView];
    if (self.chat.hasUnreadMessages) {
        [[WebimController shared].offlineSession markChatAsRead:self.chat completion:^(BOOL successful, NSError *error) {
            if (error != nil) {
                [WebimController processCommonErrorInResponse:error];
            }
        }];
    }
}

- (WMChat *)chatDataSourceCurrentChat {
    return self.chat;
}

- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message completion:(void (^)(BOOL, UIImage *, NSError *))block {
    [[WebimController shared].offlineSession downloadImageForMessage:message completion:block];
}

- (WMBaseSession *)session {
    return [WebimController shared].offlineSession;
}

#pragma mark - JSQMessagesViewController

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    WMOfflineSession *session = [WebimController shared].offlineSession;
    [session sendMessage:text inChat:self.chat onDataBlock:^(BOOL successful, WMChat *chat, WMMessage *chatMessage, NSError *error) {
        if (successful) {
            self.chat = chat;
        } else {
            self.inputToolbar.contentView.textView.text = text;
            [self tryToProcessSendMessageError:error];
        }
    } completion:^(BOOL successful) {
        [self finishSendingMessageAnimated:YES];
        [self reloadBubbleTableView];
        [self finishReceivingMessageAnimated:YES];
    }];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    // Empty to avoid raiting offline chat
}

#pragma mark - User Actions

- (IBAction)tapInTableViewGestureAction:(id)sender {
    [self.view endEditing:YES];
}

- (void)sendImage:(UIImage *)image {
    WMOfflineSession *session = [WebimController shared].offlineSession;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [session sendImage:imageData type:WMChatAttachmentImageJPEG inChat:self.chat onDataBlock:^(BOOL successful, WMChat *chat, WMMessage *message, NSError *error) {
        if (successful) {
            self.chat = chat;
            [WebimController shared].imagesMap[message.text] = image;
        } else {
            [self tryToProcessSendMessageError:error];
            NSLog(@"%@", error);
        }
    } completion:^(BOOL successful) {
        [self reloadBubbleTableView];
        [self finishReceivingMessageAnimated:YES];
    }];
}

#pragma mark - Error handers

- (void)tryToProcessSendMessageError:(NSError *)error {
    if ([WebimController processCommonErrorInResponse:error]) {
        return;
    }
    if ([error.domain isEqualToString:WMWebimErrorDomain]) {
        NSString *alertMessage = nil;
        if (error.code == WMSessionErrorVisitorBanned) {
            alertMessage = WMLocString(@"WMSessionErrorVisitorBanned");
        } else if (error.code == WMSessionErrorAttachmentSizeExceeded) {
            alertMessage = WMLocString(@"WMSessionErrorAttachmentSizeExceeded");
        } else if (error.code == WMSessionErrorMessageSizeExceeded) {
            alertMessage = WMLocString(@"WMSessionErrorMessageSizeExceeded");
        }
        if (alertMessage.length > 0) {
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:alertMessage
                                       delegate:nil
                              cancelButtonTitle:WMLocString(@"DialogDismissButton")
                              otherButtonTitles:nil] show];
        }
    }
}

#pragma mark - History update notifications

- (void)webimNotificationsDidReceiveUpdateNotification:(NSNotification *)notification {
    if (self.chat == nil ||
        [notification.userInfo[WMOfflineChatChangesNewChatsKey] containsObject:self.chat] ||
        [notification.userInfo[WMOfflineChatChangesModifiedChatsKey] containsObject:self.chat]) {
        [self reloadBubbleTableView];
        [self finishReceivingMessageAnimated:YES];
    }
}


@end
