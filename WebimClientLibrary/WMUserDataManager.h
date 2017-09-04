//
//  WMUserDataManager.h
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 30.08.17.
//  Copyright (c) 2017 Webim.ru. All rights reserved.
//


#import <Foundation/Foundation.h>


extern NSString *const WMMultiUserFilePath;
extern NSString *const WMUserFilePath;

extern NSString *const WMStoreVisitorKey;
extern NSString *const WMStoreVisitSessionIDKey;
extern NSString *const WMStorePageIDKey;
extern NSString *const WMStoreVisitorExtKey;
extern NSString *const WMStoreAreHintsEnabledKey; // Flag which demonstrates does an app have to show hints when visitor is composing a message.


// MARK: -
/*
 Class that is responsible for saving user data in Keychain.
 
 IMPORTANT
 All WMUserDataManager public methods are class methods. You do not create class instances.
 */
@interface WMUserDataManager : NSObject 

// MARK: - Methods

+ (void)migrateToArchiveClientData;

// MARK: Archiving methods
+ (void)archiveData:(NSDictionary *)data
          forUserID:(NSString *)userID;
+ (void)archiveData:(NSDictionary *)data;

// MARK: Unarchiving methods
+ (NSDictionary *)unarchiveDataFor:(NSString *)userID;
+ (NSDictionary *)unarchiveData;

@end
