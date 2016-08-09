//
//  WMRateOperatorTableViewController.m
//  Webim-Client
//
//  Created by Michael Rublev on 04/07/15.
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMRateOperatorTableViewController.h"

#import "HCSStarRatingView.h"

@interface WMRateOperatorTableViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *rateBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) IBOutlet UILabel *clarifyingTextLabel;
@property (strong, nonatomic) IBOutlet UIView *starsPlaceholderView;

@property (strong, nonatomic) HCSStarRatingView *ratingView;

@end

@implementation WMRateOperatorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = WMLocString(@"RatingTitle");
    self.rateBarButtonItem.title = WMLocString(@"RatingSendButtonTitle");
    self.cancelBarButtonItem.title = WMLocString(@"RatingCancelButtonTitle");
    self.clarifyingTextLabel.text = WMLocString(@"RatingClarifyingText");
    
    self.ratingView = [[HCSStarRatingView alloc] initWithFrame:self.starsPlaceholderView.bounds];
    [self.starsPlaceholderView addSubview:self.ratingView];
}

#pragma mark - User Actions

- (IBAction)cancelBarButtonItemAction:(id)sender {
    [self hideView];
}

- (IBAction)sendBarButtonItemAction:(id)sender {
    if ([self.ratingDeletage respondsToSelector:@selector(rateOperatorTableViewController:didRate:authorID:rateCompletion:)]) {
        [self.ratingDeletage rateOperatorTableViewController:self
                                                     didRate:(NSInteger)trunc(self.ratingView.value)
                                                    authorID:self.operatorID
                                              rateCompletion:^(BOOL success) {
                                                  [self hideView];
                                              }];
    } else {
        [self hideView];
    }
}

- (void)hideView {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.ratingDeletage respondsToSelector:@selector(rateOperatorTableViewControllerDidDismissRating:)]) {
            [self.ratingDeletage rateOperatorTableViewControllerDidDismissRating:self];
        }
    }];
}

@end
