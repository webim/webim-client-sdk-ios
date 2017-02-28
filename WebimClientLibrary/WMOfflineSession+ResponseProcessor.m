//
//  WMSession+ResponseProcessor.m
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 14/06/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import "WMOfflineSession+ResponseProcessor.h"

#import "WMChat.h"
#import "WMChat+Private.h"
#import "WMMessage.h"
#import "WMMessage+Private.h"

@implementation WMOfflineSession (ResponseProcessor)

#pragma mark - History Processor

- (NSDictionary *)processGetHistory:(id)responseObject appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock {
    NSArray *chatsArray = responseObject[@"chats"];
    NSMutableArray *newChatsArray = [NSMutableArray array];
    for (NSDictionary *chatDictionary in chatsArray) {
        WMChat *chat = [WMChat new];
        [chat initWithObject:chatDictionary forSession:self];
        [newChatsArray addObject:chat];
    }
    NSMutableDictionary *changes = [self mergeNewChatsFromArray:newChatsArray appeals:appealsArray lock:lock];
    NSMutableDictionary *messagesChanges = [self processMessages:responseObject[@"messages"] appeals:appealsArray lock:lock];
    [changes[WMOfflineChatChangesMessagesKey] addObjectsFromArray:messagesChanges[WMOfflineChatChangesMessagesKey]];
    [changes[WMOfflineChatChangesModifiedChatsKey] addObjectsFromArray:messagesChanges[WMOfflineChatChangesModifiedChatsKey]];
    return changes;
}

- (NSMutableDictionary *)mergeNewChatsFromArray:(NSArray *)newChatsArray appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock {
    NSMutableArray *chatsToAdd = [NSMutableArray array];
    NSMutableArray *editedChats = [NSMutableArray array];
    NSMutableArray *addedMessages = [NSMutableArray array];
    
    [lock lock];
    for (WMChat *newChat in newChatsArray) {
        WMChat *originalChat = [self findChatByID:newChat.uid inAppealsArray:appealsArray];
        if (originalChat == nil) {
            [chatsToAdd addObject:newChat];
            [addedMessages addObjectsFromArray:newChat.messages];
        } else {
            [originalChat copyValues:newChat];
            NSArray *newMessages = [self mergeNewMessageFromArray:newChat.messages chat:originalChat];
            if (newMessages.count > 0) {
                [addedMessages addObjectsFromArray:newMessages];
                [editedChats addObject:originalChat];
            }
        }
    }
    [appealsArray addObjectsFromArray:chatsToAdd];
    [lock unlock];
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    changes[WMOfflineChatChangesNewChatsKey] = chatsToAdd;
    changes[WMOfflineChatChangesMessagesKey] = addedMessages;
    changes[WMOfflineChatChangesModifiedChatsKey] = editedChats;
    return changes;
}

- (NSArray *)mergeNewMessageFromArray:(NSArray *)newMessagesArray chat:(WMChat *)chat {
    NSMutableArray *messagesToAdd = [NSMutableArray array];
    for (WMMessage *newMessage in newMessagesArray) {
        WMMessage *originalMessage = [self findMessageByID:newMessage.uid inChat:chat];
        if (originalMessage == nil) {
            [messagesToAdd addObject:newMessage];
        }
    }
    [chat.messages addObjectsFromArray:messagesToAdd];
    return messagesToAdd;
}

- (NSMutableDictionary *)processMessages:(NSArray *)messagesDataArray appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock {
    NSMutableArray *messagesToAdd = [NSMutableArray array];
    NSMutableArray *chatsToEdit = [NSMutableArray array];
    [lock lock];
    for (NSDictionary *messageData in messagesDataArray) {
        id chatID = messageData[@"chatId"];
        if ([chatID isKindOfClass:[NSNumber class]]) {
            chatID = [chatID stringValue];
        }
        WMChat *chat = [self findChatByID:chatID inAppealsArray:appealsArray];
        if (chat == nil) {
            NSLog(@"Error: attempt to add message to the missing chat");
            continue;
        }
        WMMessage *message = [[WMMessage alloc] initWithObject:messageData forSession:self];
        WMMessage *originalMessage = [self findMessageByID:message.uid inChat:chat];
        if (originalMessage == nil) {
            [chat.messages addObject:message];
            if ([message isFileMessage] || [message isTextMessage]) {
                //^ Only those types are important to know in unread messages
                chat.hasUnreadMessages = YES;
            }
            [messagesToAdd addObject:message];
            [chatsToEdit addObject:chat];
        }
    }
    [lock unlock];
    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    changes[WMOfflineChatChangesMessagesKey] = messagesToAdd;
    changes[WMOfflineChatChangesModifiedChatsKey] = chatsToEdit;
    return changes;
}

- (WMChat *)findChatByID:(NSString *)chatID inAppealsArray:(NSMutableArray *)appealsArray {
    for (WMChat *chat in appealsArray) {
        if ([chat.uid isEqualToString:chatID]) {
            return chat;
        }
    }
    return nil;
}

- (WMMessage *)findMessageByID:(NSString *)messageID inChat:(WMChat *)chat {
    for (WMMessage *message in chat.messages) {
        if ([message.uid isEqualToString:messageID]) {
            return message;
        }
    }
    return nil;
}

#pragma mark - Send Message Processor

- (WMChat *)processNewAppealWithMessage:(NSDictionary *)messageDictionary {
    NSDictionary *responseData = messageDictionary[@"data"];
    if (responseData == nil) {
        return nil;
    }

    WMChat *appeal = [[WMChat alloc] init];
    [appeal initWithObject:responseData forSession:self];
    return appeal;
}

- (WMMessage *)processNewMessage:(NSDictionary *)messageDictionary {
    NSDictionary *responseData = messageDictionary[@"data"];
    if (responseData == nil) {
        return nil;
    }

    WMMessage *message = [[WMMessage alloc] initWithObject:responseData forSession:self];
    return message;
}

#pragma mark -

- (void)processDeleteChat:(WMChat *)chat response:(id)responseObject appeals:(NSMutableArray *)appealsArray lock:(NSLock *)lock {
    [lock lock];
    [appealsArray removeObject:chat];
    [lock unlock];
}

- (void)processMarkAsReadChat:(WMChat *)chat response:(id)responseObject {
    chat.hasUnreadMessages = NO;
}

@end
