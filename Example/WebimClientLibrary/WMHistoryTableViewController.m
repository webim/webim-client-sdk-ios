//
//  WMHistoryTableViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMHistoryTableViewController.h"

#import "WebimController.h"

#import "WMOfflineChatViewController.h"
#import "WMHistoryCell.h"

typedef NS_ENUM(NSUInteger, ChatSectionType) {
    ChatSectionRealtime = 0,
    ChatSectionOffline = 1,
};

static WMHistoryTableViewController *sharedInastance = nil;

@interface WMHistoryTableViewController ()

@property (nonatomic, assign) BOOL presentingOfflineChat;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (strong, nonatomic) IBOutlet UIButton *startChatButton;

@end

@implementation WMHistoryTableViewController {
    BOOL    shouldReloadChat;
}

+ (void)setReopenChatOnViewDidAppear {
    if (sharedInastance != nil) {
        sharedInastance->shouldReloadChat = YES;
    }
}

- (void)viewDidLoad {
    sharedInastance = self;

    [super viewDidLoad];
    [WebimController initializeWithConfig:nil];
    [WebimController setUpdateInterval:20];
    [WebimController forceReloadHostory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onlineFullUpdateNotification:) name:WebimNotifications.onlineFullUpdate object:nil];
    [nc addObserver:self selector:@selector(onlineNewMessageNotification:) name:WebimNotifications.onlineNewMessage object:nil];
    [nc addObserver:self selector:@selector(onlineSessionStartChatNotification:) name:WebimNotifications.onlineChatStart object:nil];
    [nc addObserver:self selector:@selector(onlineSessionChatStatusChangeNotification:) name:WebimNotifications.onlineChatStatusChange object:nil];
    [nc addObserver:self selector:@selector(webimNotificationsDidReceiveUpdateNotification:) name:WebimNotifications.didReceiveUpdate object:nil];
    [nc addObserver:self selector:@selector(onlineHasOnlineOperatorChangeNotification:) name:WebimNotifications.onlineSessionHasOnlineOperatorChange object:nil];
    
    [self updateViewsOnRealtimeSessionChanges];
    [self reloadDataSourceAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (shouldReloadChat) {
        shouldReloadChat = NO;
        [self startChatButtonAction:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadDataSourceAnimated:(BOOL)animated {
    NSMutableArray *newDataSource = [[WebimController shared].offlineSession.appealsArray mutableCopy];
    [newDataSource sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WMChat *left = obj1, *right = obj2;
        WMMessage *leftMessage = left.messages.lastObject, *rightMessage = right.messages.lastObject;
        return [rightMessage.timestamp compare:leftMessage.timestamp];
    }];
    self.dataSource = newDataSource;
    if (animated) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ChatSectionOffline] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

- (void)updateStartChatButtonTitles {
    WMSession *session = [WebimController shared].realtimeSession;
    NSString *startChatTitle = session.onlineStatus == WMSessionOnlineStatusOnline ?
        WMLocString(@"HistoryStartOnlineChatButtonTitle") : WMLocString(@"HistoryStartOfflineChatButtonTitle");
    [self.startChatButton setTitle:startChatTitle forState:UIControlStateNormal];
}

- (void)updateViewsOnRealtimeSessionChanges {
    [self updateStartChatButtonTitles];
}

- (BOOL)canContinueChatInRealtimeSession:(WMSession *)session {
    WMChat *chat = session.chat;
    return !(chat == nil || chat.state == WMChatStateUnknown || chat.state == WMChatStateClosed || session.onlineStatus != WMSessionOnlineStatusOnline);
}

- (IBAction)startChatButtonAction:(id)sender {
    if ([WebimController shared].realtimeSession.onlineStatus == WMSessionOnlineStatusOnline) {
        [self performSegueWithIdentifier:@"PushChatViewController" sender:self];
    } else {
        [self performSegueWithIdentifier:@"PushNewOfflineChatViewController" sender:self];
    }
}

- (IBAction)refreshButtonAction:(id)sender {
    [WebimController forceReloadHostory];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ChatSectionRealtime) {
        return [self canContinueChatInRealtimeSession:[WebimController shared].realtimeSession];
    }
    return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = section == 0 ? WMLocString(@"HistoryCurrentChatSectionTitle") : WMLocString(@"HistoryHistoryChatSectionTitle");
    if (section == 0 && ![self canContinueChatInRealtimeSession:[WebimController shared].realtimeSession]) {
        title = nil;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WMHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    WMChat *chat = indexPath.section == ChatSectionRealtime ?
        [WebimController shared].realtimeSession.chat : [self.dataSource objectAtIndex:indexPath.row];
    WMMessage *lastMessage = [self lastTextMessageInChat:chat];
    NSString *cellTitle = lastMessage.text;
    if (lastMessage == nil) {
        lastMessage = chat.messages.lastObject;
        if (lastMessage.kind == WMMessageKindFileFromOperator) {
            cellTitle = WMLocString(@"HistoryOpratorFileMessageCellTitle");
        } else if (lastMessage.kind == WMMessageKindFileFromVisitor) {
            cellTitle = WMLocString(@"HistoryVistiorFileMessageCellTitle");
        } else {
            cellTitle = lastMessage.text;
        }
    }
    
    cell.messageTextLabel.text = cellTitle;
    cell.messageTextLabel.font = chat.hasUnreadMessages ? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17];
    cell.bulletImageView.hidden = !chat.hasUnreadMessages;
    
    BOOL canContinueChat = indexPath.section == 0 || chat.isOffline;
    CGFloat cComp = 0.95f;
    cell.backgroundColor = canContinueChat ? [UIColor whiteColor] : [UIColor colorWithRed:cComp green:cComp blue:cComp alpha:1];
    
    return cell;
}

- (WMMessage *)lastTextMessageInChat:(WMChat *)chat {
    for (WMMessage *message in [chat.messages reverseObjectEnumerator]) {
        if ([message isTextMessage]) {
            return message;
        }
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ChatSectionOffline;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WMChat *chat = self.dataSource[indexPath.row];
        [[WebimController shared].offlineSession deleteChat:chat completion:^(BOOL successful, NSError *error) {
            if (successful) {
                [self.dataSource removeObject:chat];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [WebimController processCommonErrorInResponse:error];
                [self.tableView reloadData];
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ChatSectionRealtime) {
        [self performSegueWithIdentifier:@"PushChatViewController" sender:self];
    } else {
        [self performSegueWithIdentifier:@"PushOfflineChatViewController" sender:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushOfflineChatViewController"]) {
        WMOfflineChatViewController *offlineChatVC = segue.destinationViewController;
        offlineChatVC.chat = self.dataSource[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Online Session Notification Handers

- (void)onlineFullUpdateNotification:(NSNotification *)notification {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ChatSectionRealtime] withRowAnimation:UITableViewRowAnimationFade];
    [self updateViewsOnRealtimeSessionChanges];
}

- (void)onlineNewMessageNotification:(NSNotification *)notification {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ChatSectionRealtime] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onlineSessionStartChatNotification:(NSNotification *)notification {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ChatSectionRealtime] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onlineSessionChatStatusChangeNotification:(NSNotification *)notification {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:ChatSectionRealtime] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onlineHasOnlineOperatorChangeNotification:(NSNotification *)notification {
    [self updateStartChatButtonTitles];
}

#pragma mark - Offline Session Notification Handerls

- (void)webimNotificationsDidReceiveUpdateNotification:(NSNotification *)notification {
    [self reloadDataSourceAnimated:YES];
}

@end
