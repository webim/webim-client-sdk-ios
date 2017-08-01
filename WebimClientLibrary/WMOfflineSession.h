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


// MARK: Initialization

- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                    token:(NSString *)token
                 platform:(NSString *)platform
            visitorFields:(NSDictionary *)visitorFields
              isMultiUser:(BOOL)isMultiUser;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                    token:(NSString *)token
                 platform:(NSString *)platform
            visitorFields:(NSDictionary *)visitorFields;
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location
                    token:(NSString *)token
                 platform:(NSString *)platform;


// MARK: Chat methods

- (void)getHistoryForced:(BOOL)forced
              completion:(void (^)(BOOL successful, id changes, NSError *error))block;
- (void)deleteChat:(WMChat *)chat
        completion:(void (^)(BOOL successful, NSError *error))block;
- (void)markChatAsRead:(WMChat *)chat
            completion:(void (^)(BOOL successful, NSError *error))block;


// MARK: Message methods

// MARK: Text (message)
- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
            subject:(NSString *)subject
      departmentKey:(NSString *)departmentKey
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;
- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
      departmentKey:(NSString *)departmentKey
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;
- (void)sendMessage:(NSString *)text
             inChat:(WMChat *)chat
        onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
         completion:(void (^)(BOOL successful))completion;

// MARK: File (general case)
- (void)sendFile:(NSData *)fileData
            name:(NSString *)fileName
        mimeType:(NSString *)mimeType
          inChat:(WMChat *)chat
         subject:(NSString *)subject
   departmentKey:(NSString *)departmentKey
     onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
      completion:(void (^)(BOOL successful))completion;
- (void)sendFile:(NSData *)fileData
            name:(NSString *)fileName
        mimeType:(NSString *)mimeType
          inChat:(WMChat *)chat
   departmentKey:(NSString *)departmentKey
     onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
      completion:(void (^)(BOOL successful))completion;

// MARK: Image
- (void)sendImage:(NSData *)imageData
             type:(WMChatAttachmentImageType)type
           inChat:(WMChat *)chat
          subject:(NSString *)subject
    departmentKey:(NSString *)departmentKey
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
      onDataBlock:(void (^)(BOOL successful, WMChat *chat, WMMessage *message, NSError *error))block
       completion:(void (^)(BOOL successful))completion;


- (WMChat *)chatForMessage:(WMMessage *)message;

@end
