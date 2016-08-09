//
//  WMOfflineSession.h
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 09/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WMBaseSession.h"

@class WMChat;
@class WMMessage;

extern NSString *const WMOfflineChatChangesNewChatsKey;
extern NSString *const WMOfflineChatChangesModifiedChatsKey;
extern NSString *const WMOfflineChatChangesMessagesKey;

@interface WMOfflineSession : WMBaseSession

@property (nonatomic, strong) NSMutableArray *appealsArray;

- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                    token:(NSString *)token
                 platform:(NSString *)platform;

- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                    token:(NSString *)token
                 platform:(NSString *)platform
            visitorFields:(NSDictionary *)visitorFields;

- (void)getHistoryForced:(BOOL)forced
              completion:(void (^)(BOOL successful, id changes, NSError *error))block;

- (void)deleteChat:(WMChat *)chat
        completion:(void (^)(BOOL successful, NSError *error))block;

- (void)markChatAsRead:(WMChat *)chat
            completion:(void (^)(BOOL successful, NSError *error))block;

// Send Message

- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;

- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
      departmentKey:(NSString *)departmentKey
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;

- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
            subject:(NSString *)subject
      departmentKey:(NSString *)departmentKey
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;

// Send Image

- (void)sendImage:(NSData *)imageData
             type:(WMChatAttachmentImageType)type
           inChat:(WMChat *)chat
      onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
       completion:(void (^)(BOOL successful))completion;

- (void)sendImage:(NSData *)imageData
             type:(WMChatAttachmentImageType)type
           inChat:(WMChat *)chat
    departmentKey:(NSString *)departmentKey
      onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
       completion:(void (^)(BOOL successful))completion;

- (void)sendImage:(NSData *)imageData
             type:(WMChatAttachmentImageType)type
           inChat:(WMChat *)chat
          subject:(NSString *)subject
    departmentKey:(NSString *)departmentKey
      onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
       completion:(void (^)(BOOL successful))completion;

// Send File

- (void)sendFile:(NSData *)fileData
            name:(NSString *)fileName
        mimeType:(NSString *)mimeType
          inChat:(WMChat *)chat
   departmentKey:(NSString *)departmentKey
     onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
      completion:(void (^)(BOOL successful))completion;

- (void)sendFile:(NSData *)fileData
            name:(NSString *)fileName
        mimeType:(NSString *)mimeType
          inChat:(WMChat *)chat
         subject:(NSString *)subject
   departmentKey:(NSString *)departmentKey
     onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
      completion:(void (^)(BOOL successful))completion;


- (WMChat *)chatForMessage:(WMMessage *)message;

@end
