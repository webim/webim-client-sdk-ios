//
//  WMMessage+Private.m
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//


#import "WMMessage+Private.h"

#import "WMBaseSession.h"
#import "WMFileParams.h"


@implementation WMMessage (Private)

- (WMMessage *)initWithObject:(NSDictionary *)object
                   forSession:(WMBaseSession *)session {
    if ((self = [super init])) {
        id authorID = object[@"authorId"];
        self.authorID = [authorID isKindOfClass:[NSNull class]] ? nil : [authorID stringValue];
        
        id avatar = object[@"avatar"];
        self.avatar = [avatar isKindOfClass:[NSNull class]] ? nil : avatar;
        
        id data = object[@"data"];
        self.data = [data isKindOfClass:[NSNull class]] ? nil : data;
        
        id name = object[@"name"];
        self.name = [name isKindOfClass:[NSNull class]] ? nil : name;
        
        self.clientSideId = object[@"clientSideId"];
        self.kind = [self messageKindFromString:object[@"kind"]];
        self.rawData = object[@"text"];
        self.session = session;
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[object[@"ts"] doubleValue]];
        self.uid = object[@"id"];
        
        [self maybeApplyFileParams];
    }
    
    return self;
}

- (void)maybeApplyFileParams {
    if ([self isFileMessage] &&
        (self.rawData.length > 0)) {
        NSData *data = [self.rawData dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
        if (error == nil) {
            self.fileParams = [WMFileParams createWithObject:params];
        }
    }
}

- (WMMessageKind)messageKindFromString:(NSString *)messageKind {
    if ([@"action_request" isEqualToString:messageKind]) {
        return WMMessageKindActionRequest;
    } else if ([@"cont_req" isEqualToString:messageKind]) {
        return WMMessageKindContactsRequest;
    } else if ([@"contacts" isEqualToString:messageKind]) {
        return WMMessageKindContacts;
    } else if ([@"file_operator" isEqualToString:messageKind]) {
        return WMMessageKindFileFromOperator;
    } else if ([@"file_visitor" isEqualToString:messageKind]) {
        return WMMessageKindFileFromVisitor;
    } else if ([@"for_operator" isEqualToString:messageKind]) {
        return WMMessageKindForOperator;
    } else if ([@"info" isEqualToString:messageKind]) {
        return WMMessageKindInfo;
    } else if ([@"operator" isEqualToString:messageKind]) {
        return WMMessageKindOperator;
    } else if ([@"operator_busy" isEqualToString:messageKind]) {
        return WMMessageKindOperatorBusy;
    } else if ([@"visitor" isEqualToString:messageKind]) {
        return WMMessageKindVisitor;
    }
    
    return WMMessageKindUnknown;
}


// MARK: NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.authorID = [aDecoder decodeObjectForKey:@"authorId"];
    self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
    self.clientSideId = [aDecoder decodeObjectForKey:@"clientSideId"];
    self.data = [aDecoder decodeObjectForKey:@"data"];
    self.kind = (WMMessageKind)[aDecoder decodeIntegerForKey:@"kind"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.rawData = [aDecoder decodeObjectForKey:@"rawData"];
    self.timestamp = [aDecoder decodeObjectForKey:@"ts"];
    self.uid = [aDecoder decodeObjectForKey:@"uid"];
    
    [self maybeApplyFileParams];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.authorID forKey:@"authorId"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.clientSideId forKey:@"clientSideId"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeInt:self.kind forKey:@"kind"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.rawData forKey:@"rawData"];
    [aCoder encodeObject:self.timestamp forKey:@"ts"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
}

@end
