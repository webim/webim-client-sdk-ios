//
//  NSUserDefaults+ClientData.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 18/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//


#import "NSUserDefaults+ClientData.h"


NSString *const WMUserDefaultsRootKey = @"WebimUserDefaults";
NSString *const WMUserDefaultsMURootKey = @"WebimUserDefaultsMultiUser_";

NSString *const WMStoreVisitorKey = @"visitor";
NSString *const WMStoreVisitSessionIDKey = @"visitSessionId";
NSString *const WMStorePageIDKey = @"pageID";
NSString *const WMStoreVisitorExtKey = @"visitor-ext";
NSString *const WMStoreAreHintsEnabled = @"hintsEnabled";


@implementation NSUserDefaults (ClientData)

+ (void)archiveClientData:(NSDictionary *)dictionary {
    [[NSUserDefaults standardUserDefaults] archive:dictionary
                                           withKey:WMUserDefaultsRootKey];
}

+ (void)archiveClientDataMU:(NSString *)userId
                 dictionary:(NSDictionary *)dictionary {
    [[NSUserDefaults standardUserDefaults] archive:dictionary
                                           withKey:[WMUserDefaultsMURootKey
                                                    stringByAppendingString:userId]];
}

- (BOOL)archive:(NSDictionary *)dict
        withKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (dict != nil) {
        @try {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
            [defaults setObject:data
                         forKey:key];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            
            return NO;
        }
    } else {
        [defaults removeObjectForKey:key];
    }
    
    return [defaults synchronize];
}

+ (NSDictionary *)unarchiveClientData {
    return [[NSUserDefaults standardUserDefaults] unarchiveForKey:WMUserDefaultsRootKey];
}

+ (NSDictionary *)unarchiveClientDataMU:(NSString *)userId {
    return [[NSUserDefaults standardUserDefaults] unarchiveForKey:[WMUserDefaultsMURootKey stringByAppendingString:userId]];
}

- (NSDictionary *)unarchiveForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:key];
    NSDictionary *userDict = nil;
    if (data != nil) {
        @try {
            userDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
            
            return nil;
        }
    }
    
    return userDict;
}

+ (void)migrateToArchiveClientData {
    if ([NSUserDefaults unarchiveClientData].count > 0) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *visitor = [userDefaults valueForKey:@"visitor"];
    NSString *visitSessionId = [userDefaults valueForKey:@"visitSessionId"];
    NSString *pageID = [userDefaults valueForKey:@"pageID"];
    
    [userDefaults removeObjectForKey:@"visitor"];
    [userDefaults removeObjectForKey:@"visitSessionId"];
    [userDefaults removeObjectForKey:@"pageID"];
    
    NSMutableDictionary *clientData = [NSMutableDictionary dictionary];
    if (visitor != nil) {
        clientData[WMStoreVisitorKey] = visitor;
    }
    if (visitSessionId != nil) {
        clientData[WMStoreVisitSessionIDKey] = visitSessionId;
    }
    if (pageID != nil) {
        clientData[WMStorePageIDKey] = pageID;
    }
    [NSUserDefaults archiveClientData:clientData];
}

@end
