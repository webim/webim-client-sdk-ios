//
//  WMChat+Private.m
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChat+Private.h"

#import "WMMessage+Private.h"
#import "WMOperator+Private.h"

#import "WMBaseSession.h"


@implementation WMChat (Private)

- (void)initWithObject:(NSDictionary *)object
            forSession:(WMBaseSession *)session {
    self.isOffline = [object[@"offline"] boolValue];
    self.state = [self chatStateFromString:object[@"state"]];
    id unreadByOperatorTSObject = object[@"unreadByOperatorSinceTs"];
    
    if (![unreadByOperatorTSObject isKindOfClass:[NSNull class]]) {
        self.unreadByOperatorTimestamp = [NSDate dateWithTimeIntervalSince1970:[unreadByOperatorTSObject doubleValue]];
    }
    
    self.messages = [self messagesFromChatObject:object
                                         session:session];
    self.chatOperator = [self operatorFromObject:object[@"operator"]];
    
    id chatUID = object[@"id"];
    if ([chatUID isKindOfClass:[NSString class]]) {
        self.uid = chatUID;
    } else if ([chatUID isKindOfClass:[NSNumber class]]) {
        self.uid = [chatUID stringValue];
    }
    
    id hasUnreadMessagesData = object[@"unreadByVisitorSinceTs"];
    
    self.hasUnreadMessages = !((hasUnreadMessagesData == nil) ||
                               [hasUnreadMessagesData isKindOfClass:[NSNull class]]);
    self.operatorTyping = object[@"operatorTyping"] ? [object[@"operatorTyping"] boolValue] : NO;
    self.proposeToRateBeforeClose = NO;

    id clientSideId = object[@"clientSideId"];
    if ((clientSideId != nil) &&
         ![clientSideId isKindOfClass:[NSNull class]]) {
        self.clientSideId = clientSideId;
    }
}

- (WMChatState)chatStateFromString:(NSString *)stateString {
    if ([@"queue" isEqualToString:stateString]) {
        return WMChatStateQueue;
    }
    
    if ([@"chatting" isEqualToString:stateString]) {
        return WMChatStateChatting;
    }
    
    if ([@"closed" isEqualToString:stateString]) {
        return WMChatStateClosed;
    }
    
    if ([@"closed_by_visitor" isEqualToString:stateString]) {
        return WMChatStateClosedByVisitor;
    }
    
    if ([@"closed_by_operator" isEqualToString:stateString]) {
        return WMChatStateClosedByOperator;
    }
    
    if ([@"invitation" isEqualToString:stateString]) {
        return WMChatStateInvitation;
    }
    
    return WMChatStateUnknown;
}

- (NSMutableArray *)messagesFromChatObject:(NSDictionary *)chatObject
                                   session:(WMBaseSession *)session {
    NSMutableArray *messages = [NSMutableArray array];
    id messagesData = chatObject[@"messages"];
    
    if ((messagesData == nil) ||
        [messagesData isKindOfClass:[NSNull class]]) {
        return messages;
    }
    
    for (NSDictionary *message in messagesData) {
        WMMessage *newMessage = [[WMMessage alloc] initWithObject:message
                                                       forSession:session];
        [messages addObject:newMessage];
    }
    
    return messages;
}

- (WMOperator *)operatorFromObject:(NSDictionary *)object {
    if ((object == nil) ||
        [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return [[WMOperator alloc] initWithObject:object];
}

- (void)copyValues:(WMChat *)fromObject {
    self.isOffline = fromObject.isOffline;
    self.state = fromObject.state;
    self.unreadByOperatorTimestamp = fromObject.unreadByOperatorTimestamp;
    self.hasUnreadMessages = fromObject.hasUnreadMessages;
}


// MARK: NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.uid = [aDecoder decodeObjectForKey:@"chat_uid"];
    self.hasUnreadMessages = [aDecoder decodeBoolForKey:@"has_unread"];
    self.messages = [aDecoder decodeObjectForKey:@"messages"];
    self.isOffline = [aDecoder decodeBoolForKey:@"isOffline"];
    self.state = (WMChatState)[aDecoder decodeIntegerForKey:@"state"];
    self.clientSideId = [aDecoder decodeObjectForKey:@"clientSideId"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:@"chat_uid"];
    [aCoder encodeBool:self.hasUnreadMessages forKey:@"has_unread"];
    [aCoder encodeObject:self.messages forKey:@"messages"];
    [aCoder encodeBool:self.isOffline forKey:@"isOffline"];
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeObject:self.clientSideId forKey:@"clientSideId"];
}

@end
