//
//  WMImageParams.h
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//


#import <Foundation/Foundation.h>


@class WMImageSize;


@interface WMImageParams : NSObject

@property (nonatomic, strong) WMImageSize *size;

+ (WMImageParams *)createWithObject:(id)object;

@end
