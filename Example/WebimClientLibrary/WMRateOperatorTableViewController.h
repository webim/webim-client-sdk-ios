//
//  WMRateOperatorTableViewController.h
//  Webim-Client
//
//  Created by Michael Rublev on 04/07/15.
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WMRateOperatorTVCProtocol;


@interface WMRateOperatorTableViewController : UITableViewController

@property (nonatomic, weak) id<WMRateOperatorTVCProtocol> ratingDeletage;

@property (nonatomic, strong) NSString *operatorID;

@end


@protocol WMRateOperatorTVCProtocol <NSObject>
- (void)rateOperatorTableViewControllerDidDismissRating:(WMRateOperatorTableViewController *)tvc;
- (void)rateOperatorTableViewController:(WMRateOperatorTableViewController *)tvc didRate:(NSInteger)rate authorID:(NSString *)authorID rateCompletion:(void (^)(BOOL success))block;
@end
