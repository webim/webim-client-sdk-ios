//
//  WMFileParams.h
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMImageParams;


@interface WMFileParams : NSObject

@property (nonatomic, assign) NSUInteger size;

@property (nonatomic, strong) NSString *guid;

@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) NSString *contentType;

@property (nonatomic, strong) WMImageParams *imageParams;


// For internal usage
+ (WMFileParams *)createWithObject:(id)object;

@end
