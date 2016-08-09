//
//  WMChatBaseViewController.h
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessages.h"

#import "WMRateOperatorTableViewController.h"

@class WMBaseSession;

@interface WMChatBaseViewController : JSQMessagesViewController <WMRateOperatorTVCProtocol>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *operatorBarButtonItem;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

- (IBAction)cameraButtonAction:(id)sender;

- (void)sendImage:(UIImage *)image;

- (WMBaseSession *)session;

- (void)openOperatorRatingView:(NSString *)authorID;

@end
