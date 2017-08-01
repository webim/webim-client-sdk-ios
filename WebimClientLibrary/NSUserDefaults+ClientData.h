//
//  NSUserDefaults+ClientData.h
//  WebimClientLibrary
//
//  Created by Michael Rublev on 18/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//


#import <Foundation/Foundation.h>


extern NSString *const WMUserDefaultsRootKey;
extern NSString *const WMUserDefaultsMURootKey;

extern NSString *const WMStoreVisitorKey;
extern NSString *const WMStoreVisitSessionIDKey;
extern NSString *const WMStorePageIDKey;
extern NSString *const WMStoreVisitorExtKey;
extern NSString *const WMStoreAreHintsEnabled; // Flag which demonstrates does an app have to show hints when visitor is composing a message


@interface NSUserDefaults (ClientData)

+ (void)archiveClientData:(NSDictionary *)dictionary;
+ (NSDictionary *)unarchiveClientData;
+ (void)migrateToArchiveClientData;

+ (void)archiveClientDataMU:(NSString *)userId
                 dictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)unarchiveClientDataMU:(NSString *)userId;

- (BOOL)archive:(NSDictionary *)dict
        withKey:(NSString *)key;
- (NSDictionary *)unarchiveForKey:(NSString *)key;

@end
