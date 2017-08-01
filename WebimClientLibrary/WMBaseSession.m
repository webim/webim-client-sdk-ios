//
//  WMBaseSession.m
//  WebimClientLibrary
//
//  Created by Oleg Bogumirsky on 09/07/14.
//  Copyright (c) 2014 Webim.ru. All rights reserved.
//

#import "WMBaseSession.h"

#import "NSUserDefaults+ClientData.h"
#import "AFNetworking.h"
#import "WMMessage.h"


static NSString *DomainURLFormat   = @"https://%@.webim.ru";

NSString *const WMWebimErrorDomain = @"WebimErrorDomain";


@implementation WMBaseSession

// MARK: Initialization
- (id)initWithAccountName:(NSString *)accountName
                 location:(NSString *)location {
    if ((self = [super init])) {
        _accountName = accountName;
        _location = location;
        
        [NSUserDefaults migrateToArchiveClientData];
    }
    
    return self;
}


- (void)setLocation:(NSString *)location {
    _location = location;
    
    NSMutableDictionary *storedValues = [[NSUserDefaults unarchiveClientData] mutableCopy];
    [storedValues removeObjectForKey:WMStorePageIDKey];
    [NSUserDefaults archiveClientData:storedValues];
}

- (NSString *)host {
    if (self.accountName == nil) {
        return nil;
    }
    
    if ([self.accountName containsString:@"://"]) {
        return self.accountName;
    }
    
    return [NSString stringWithFormat:DomainURLFormat, self.accountName];
}

- (void)clearCachedUserData {
    
}

- (NSURL *)attachmentURLForMessage:(WMMessage *)message {
    if (![message isFileMessage]) {
        return nil;
    }
    
    NSString *path = [message.filePath
                      stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *downloadString = [NSString stringWithFormat:@"%@/%@", self.host, path];
    return [NSURL URLWithString:downloadString];
}

- (void)downloadImageForMessage:(WMMessage *)message
                     completion:(void (^)(BOOL successful, UIImage *image, NSError *error))block {
    NSURL *imageURL = [message fileURL];
    if (imageURL == nil) {
        NSError *error = [NSError errorWithDomain:WMWebimErrorDomain
                                             code:WMSessionErrorUnknown
                                         userInfo:@{NSLocalizedDescriptionKey: @"Unable to get image URL"}];
        CALL_BLOCK(block, NO, nil, error);
        
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:^UIImage *(UIImage *image) {
                                                                                  return image;
                                                                              } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                  CALL_BLOCK(block, YES, image, nil);
                                                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                  CALL_BLOCK(block, NO, nil, error);
                                                                              }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)downloadImagePreviewForMessage:(WMMessage *)message
                                   key:(NSString *)key
                            completion:(void (^)(BOOL, UIImage *, NSError *))block {
    NSURL *previewURL = [message imagePreviewURLForKey:key];
    if (previewURL == nil) {
        NSError *error = [NSError errorWithDomain:WMWebimErrorDomain
                                             code:WMSessionErrorNotConfigured
                                         userInfo:@{NSLocalizedDescriptionKey: @"Preview allowed only for images"}];
        CALL_BLOCK(block, NO, nil, error);
        
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:previewURL];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:^UIImage *(UIImage *image) {
                                                                                  return image;
                                                                              } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                  CALL_BLOCK(block, YES, image, nil);
                                                                              } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                  CALL_BLOCK(block, NO, nil, error);
                                                                              }];
    [self enqueueHTTPRequestOperation:operation];
}

- (void)enqueueHTTPRequestOperation:(id)operation {
    
}

@end
