//
//  WMChatViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatViewController.h"

#import "WebimController.h"
#import "WMHistoryTableViewController.h"
#import "WMRateOperatorTableViewController.h"

#import "WMSession.h"
#import "WMChat.h"
#import "WMOperator.h"
#import "WMMessage.h"

typedef NS_ENUM(NSInteger, AlertIndex) {
    AlertIndexClosingChat,
    AlertIndexSendOffline,
};

@interface WMChatViewController () <UIAlertViewDelegate, WMChatDataSourceProtocol>

@end

@implementation WMChatViewController {
    BOOL sendingMessage_;
    BOOL didStartComposing_;
    BOOL closeAfterRate_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(onlineSessionNewMessageNotification:)
                               name:WebimNotifications.onlineNewMessage
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(onlineSessionOperatorUpdateNotification:)
                               name:WebimNotifications.onlineOperatorUpdate object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(onlineSessionStartChatNotification:)
                               name:WebimNotifications.onlineChatStart
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(onlineSessionChatStatusChangeNotification:)
                               name:WebimNotifications.onlineChatStatusChange
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(onlineSessionStatusChangeNotification:)
                               name:WebimNotifications.onlineSessionStatusChange
                             object:nil];
    
    WMSession *session = [WebimController shared].realtimeSession;
    [session startChat:^(BOOL successful) {
        [self reloadChat];
    }];
}

- (WMBaseSession *)session {
    return [WebimController shared].realtimeSession;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reloadBubbleTableView];
}

- (WMChat *)chatDataSourceCurrentChat {
    return [WebimController shared].realtimeSession.chat;
}

- (void)chatDataSourceDownloadImageForMessage:(WMMessage *)message
                                   completion:(void (^)(BOOL, UIImage *, NSError *))block {
    [[WebimController shared].realtimeSession downloadImageForMessage:message
                                                           completion:block];
}

- (void)reloadBubbleTableView {
    [super reloadBubbleTableView];
    
    WMSession *session = [WebimController shared].realtimeSession;
    if (session.chat.hasUnreadMessages) {
        [session markChatAsRead:nil];
    }
}


#pragma mark - JSQMessagesViewController

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    
    [[WebimController shared].realtimeSession sendMessage:text
                                             successBlock:^(NSString *clientSideId) {
                                                 [self finishSendingMessageAnimated:YES];
                                             } failureBlock:^(NSString *clientSideId, WMSessionError error) {
                                                 [self finishSendingMessageAnimated:YES];
                                             }];
}

#pragma mark - User Actions

- (IBAction)closeChatBarButtonAction:(id)sender {
    NSString *message = WMLocString(@"CloseChatConfirmationAlertMessage");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:WMLocString(@"DialogCancelButton")
                                          otherButtonTitles:WMLocString(@"DialogYesButton"), nil];
    alert.tag = AlertIndexClosingChat;
    [alert show];
}

- (IBAction)tapInTableViewGestureAction:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    return !sendingMessage_;
}

- (void)showUnableToStartOnlineChatAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WMLocString(@"NoOnlineOperatorsAlertTitle")
                                                    message:WMLocString(@"NoOnlineOperatorsAlertMessage")
                                                   delegate:self
                                          cancelButtonTitle:WMLocString(@"NoOnlineOperatorsAlertCloseButtonTitle")
                                          otherButtonTitles:WMLocString(@"NoOnlineOperatorsAlertStartOfflineChatButtonTitle"), nil];
    alert.tag = AlertIndexSendOffline;
    [alert show];
}

- (IBAction)textInputValueChanged:(id)sender {
    if (!didStartComposing_) {
        didStartComposing_ = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(cancelComposingState:)
                                                   object:nil];
        
        [[WebimController shared].realtimeSession setComposingMessage:YES
                                                                draft:@""];
        [self performSelector:@selector(cancelComposingState:)
                   withObject:nil
                   afterDelay:7];
    }
}

- (void)cancelComposingState:(id)sender {
    didStartComposing_ = NO;
    [[WebimController shared].realtimeSession setComposingMessage:NO
                                                            draft:@""];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertIndexClosingChat) {
        [self closeChatAlertView:alertView clickedButtonAtIndex:buttonIndex];
    } else if (alertView.tag == AlertIndexSendOffline) {
        [self goOfflineAlertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)closeChatAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self.view endEditing:YES];
        
        if (self.chatDataSourceCurrentChat.proposeToRateBeforeClose) {
            closeAfterRate_ = YES;
            [self openOperatorRatingView:self.chatDataSourceCurrentChat.chatOperator.uid];
        } else {
            [self closeChat];
        }
    }
}

- (void)closeChat {
    [[WebimController shared].realtimeSession closeChat:^(BOOL successful) {
        if (successful) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)goOfflineAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [WMHistoryTableViewController setReopenChatOnViewDidAppear];
    }
}

- (void)sendImage:(UIImage *)image {
    WMSession *session = [WebimController shared].realtimeSession;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
#if 1
    [session sendImage:imageData
                  type:WMChatAttachmentImageJPEG
            completion:^(BOOL successful) {
                ;
            }];
#else
    // Optionaly file could be sent this way
    [session sendFile:imageData
                 name:@"anyfile.jpg"
             mimeType:@"image/jpg"
           completion:nil];
#endif
}

- (void)reloadChat {
    [self reloadBubbleTableView];
}

#pragma mark - WMRateOperatorTVCProtocol

- (void)rateOperatorTableViewControllerDidDismissRating:(WMRateOperatorTableViewController *)tvc {
    if (closeAfterRate_) {
        [self closeChat];
        closeAfterRate_ = NO;
    }
}

- (void)rateOperatorTableViewController:(WMRateOperatorTableViewController *)tvc
                                didRate:(NSInteger)rate authorID:(NSString *)authorID
                         rateCompletion:(void (^)(BOOL))block {
    WMOperatorRate wmRate = rate - 2;
    [[WebimController shared].realtimeSession rateOperator:authorID
                                                  withRate:wmRate
                                                completion:^(BOOL successful) {
        if (block != nil) {
            block(successful);
        }
    }];
}

#pragma mark - Online Session Notification Handlers

- (void)onlineSessionFullUpdateNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionNewMessageNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
    WMMessage *message = notification.object;
    if ((message != nil) && !((message.kind == WMMessageKindVisitor)
                              || (message.kind == WMMessageKindFileFromVisitor))) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    }
    
    [self finishReceivingMessageAnimated:YES];
}

- (void)onlineSessionOperatorUpdateNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionStartChatNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionChatStatusChangeNotification:(NSNotification *)notification {
    NSLog(@"Chat notification: %@", NSStringFromSelector(_cmd));
    [self reloadChat];
}

- (void)onlineSessionStatusChangeNotification:(NSNotification *)notification {
    if ([WebimController shared].realtimeSession.state == WMSessionStateOfflineMessage) {
        [self showUnableToStartOnlineChatAlert];
    }
}

@end
