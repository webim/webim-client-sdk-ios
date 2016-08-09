//
//  WMChatBaseViewController.m
//  Webim-Client
//
//  Copyright (c) 2015 WEBIM.RU Ltd. All rights reserved.
//

#import "WMChatBaseViewController.h"

#import "UIImage+OrientationFix.h"

static NSString *ChatToRatingSegue = @"ModalSegueToRateNavigationViewController";

@interface WMChatBaseViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation WMChatBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ChatToRatingSegue]) {
        UINavigationController *nvc = segue.destinationViewController;
        WMRateOperatorTableViewController *rateTVC = nvc.viewControllers.firstObject;
        rateTVC.ratingDeletage = self;
        rateTVC.operatorID = sender;
    }
}

- (void)openOperatorRatingView:(NSString *)authorID {
    [self performSegueWithIdentifier:ChatToRatingSegue sender:authorID];
}

- (IBAction)openWebimLink:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://webim.ru"]];
}

- (IBAction)cameraButtonAction:(id)sender {
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:WMLocString(@"DialogCancelButton")
                       destructiveButtonTitle:nil
                       otherButtonTitles:WMLocString(@"ImagePickerUseCamera"), WMLocString(@"ImagePickerUserPhotos"), nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil delegate:self
                       cancelButtonTitle:WMLocString(@"DialogCancelButton")
                       destructiveButtonTitle:nil
                       otherButtonTitles:WMLocString(@"ImagePickerUserPhotos"), nil];
    }
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {
            [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (buttonIndex == 1) {
            [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    } else {
        [self pickPhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)pickPhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        if (self.imagePickerController == nil) {
            self.imagePickerController = [[UIImagePickerController alloc] init];
        }
        self.imagePickerController.delegate = self;
        self.imagePickerController.sourceType = sourceType;
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self sendImage:[image imageWithOrientationUp]];
}

- (void)sendImage:(UIImage *)image {
}

- (WMBaseSession *)session {
    return nil;
}

- (void)rateOperatorTableViewControllerDidDismissRating:(WMRateOperatorTableViewController *)tvc {
}

- (void)rateOperatorTableViewController:(WMRateOperatorTableViewController *)tvc didRate:(NSInteger)rate authorID:(NSString *)authorID rateCompletion:(void (^)(BOOL))block {
}

@end
