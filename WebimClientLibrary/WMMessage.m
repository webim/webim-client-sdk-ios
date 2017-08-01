//
//  WMMessage.m
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//


#import "WMMessage.h"

#import "WMBaseSession.h"
#import "WMFileParams.h"


@implementation WMMessage

- (NSString *)text {
    return [self isFileMessage] ? self.fileParams.filename : self.rawData;
}

- (NSString *)filePath {
    if ([self isFileMessage]) {
        return [NSString stringWithFormat:@"l/v/download/%@/%@", self.fileParams.guid, self.fileParams.filename];
    }
    
    return nil;
}

- (NSURL *)fileURL {
    if (![self isFileMessage]) {
        return nil;
    }
    
    NSCharacterSet *allowedSet = [NSCharacterSet URLPathAllowedCharacterSet];
    NSString *path = [[self filePath] stringByAddingPercentEncodingWithAllowedCharacters:allowedSet];
    NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@", self.session.host, path];
    
    return [NSURL URLWithString:fullUrlString];
}

- (NSURL *)imagePreviewURLForKey:(NSString *)key {
    if (![self isFileMessage] ||
        (key.length == 0)) {
        return nil;
    }
    
    if ((self.fileParams == nil) ||
        (self.fileParams.imageParams == nil) ||
        (self.session == nil) ||
        (self.session.host == nil)) {
        return nil;
    }

    NSCharacterSet *allowedSet = [NSCharacterSet URLPathAllowedCharacterSet];
    NSString *path = [[self filePath] stringByAddingPercentEncodingWithAllowedCharacters:allowedSet];
    NSString *fullUrlString = [NSString stringWithFormat:@"%@/%@?thumb=%@", self.session.host, path, key];
    
    return [NSURL URLWithString:fullUrlString];
}

- (BOOL)isTextMessage {
    return ((_kind == WMMessageKindVisitor) ||
            (_kind == WMMessageKindOperator));
}

- (BOOL)isFileMessage {
    return ((_kind == WMMessageKindFileFromOperator) ||
            (_kind == WMMessageKindFileFromVisitor));
}

- (NSURL *)senderAvatarURL {
    if ((self.avatar.length == 0) ||
        (self.session == nil) ||
        (self.session.host == nil)) {
        return nil;
    }
    
    NSString *path = [self.avatar stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *fullUri = [NSString stringWithFormat:@"%@/%@", self.session.host, path];
    return [NSURL URLWithString:fullUri];
}

- (NSString *)senderUID {
    return self.authorID;
}

- (NSString *)senderName {
    return self.name;
}

@end
