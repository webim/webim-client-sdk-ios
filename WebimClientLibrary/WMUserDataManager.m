//
//  WMUserDataManager.m
//  WebimClientLibrary
//
//  Created by Nikita Lazarev-Zubov on 30.08.17.
//  Copyright (c) 2017 Webim.ru. All rights reserved.
//


#import "WMUserDataManager.h"

#import "KeychainItemWrapper/KeychainItemWrapper.h"


// MARK: - Constants
NSString *const WMMultiUserFilePath = @"WebimMultiUserData";
NSString *const WMUserFilePath = @"WebimUserData";

NSString *const WMStoreVisitorKey = @"visitor";
NSString *const WMStoreVisitSessionIDKey = @"visitSessionId";
NSString *const WMStorePageIDKey = @"pageID";
NSString *const WMStoreVisitorExtKey = @"visitor-ext";
NSString *const WMStoreAreHintsEnabledKey = @"hintsEnabled";

NSString *const WMKeychainIdentifier = @"WMUserData";


// MARK: -
@interface WMUserDataManager ()

// MARK: - Properties
/* Those are private and to be used only by private methods. */
@property (nonatomic, strong) KeychainItemWrapper *keychain;

@end


// MARK: -
@implementation WMUserDataManager

// MARK: - Initialization
/* To be used NOT. Initializer is only for 'shared' method. */
- (id)init {
    if (self = [super init]) {
        self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:WMKeychainIdentifier
                                                            accessGroup:nil];
    }
    
    return self;
}

// MARK: - Methods

/* 
 WMUserDataManager has to have only one instance which is returned by this method.
 In fact the only methods that use the class instance are private so a user never create any class instance.
 */
+ (id)shared {
    static WMUserDataManager *shared = nil;
    @synchronized (self) {
        if (shared == nil) {
            shared = [[self alloc] init];
        }
    }
    
    return shared;
}

+ (void)migrateToArchiveClientData {
    if ([WMUserDataManager unarchiveData].count > 0) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *visitor = [userDefaults valueForKey:WMStoreVisitorKey];
    NSString *visitSessionID = [userDefaults valueForKey:WMStoreVisitSessionIDKey];
    NSString *pageID = [userDefaults valueForKey:WMStorePageIDKey];
    
    [userDefaults removeObjectForKey:WMStoreVisitorKey];
    [userDefaults removeObjectForKey:WMStoreVisitSessionIDKey];
    [userDefaults removeObjectForKey:WMStorePageIDKey];
    
    NSMutableDictionary *clientData;
    if (visitor != nil) {
        clientData[WMStoreVisitorKey] = visitor;
    }
    if (visitSessionID != nil) {
        clientData[WMStoreVisitSessionIDKey] = visitSessionID;
    }
    if (pageID != nil) {
        clientData[WMStorePageIDKey] = pageID;
    }
    NSDictionary *immutableClientData = [NSDictionary dictionaryWithDictionary:clientData];
    
    [WMUserDataManager archiveData:immutableClientData];
}

// MARK: Archiving methods

+ (void)archiveData:(NSDictionary *)data
          forUserID:(NSString *)userID {
    if ((userID == nil)
        || (data == nil)) {
        [[WMUserDataManager shared] archiveUserData:data];
        return;
    }
    
    NSDictionary *userDataDictionary = @{
                                         userID : data
                                         };
    [[WMUserDataManager shared] archiveUserData:userDataDictionary];
}

+ (void)archiveData:(NSDictionary *)data {
    [[WMUserDataManager shared] archiveUserData:data];
}


// MARK: Unarchiving methods

+ (NSDictionary *)unarchiveDataFor:(NSString *)userID {
    if (userID == nil) {
        return [[WMUserDataManager shared] unarchiveUserData];
    }
    
    NSDictionary *multiUserDictionary = [[WMUserDataManager shared] unarchiveUserData];
    
    return [multiUserDictionary objectForKey:userID];
}

+ (NSDictionary *)unarchiveData {
    return [[WMUserDataManager shared] unarchiveUserData];
}


// MARK: - Private methods
/* Uses KeychainItemWrapper class for archiving user data in Keychain. */

- (void)archiveUserData:(NSDictionary *)data {
    if (data == nil) {
        [self.keychain resetKeychainItem];
        
        return;
    }
    
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [self.keychain setObject:userData
                      forKey:(__bridge id)kSecValueData];
}

- (NSDictionary *)unarchiveUserData {
    NSData *userData = [self.keychain objectForKey:(__bridge id)kSecValueData];
    NSDictionary *userDataDictionary = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    
    return userDataDictionary;
}

@end
