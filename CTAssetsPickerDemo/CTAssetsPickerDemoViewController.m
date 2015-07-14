//
//  CTAssetsPickerDemoViewController.m
//  CTAssetsPickerDemo
//
//  Created by wshaolin on 15/7/13.
//  Copyright (c) 2015年 神州锐达（北京）科技有限公司. All rights reserved.
//

#import "CTAssetsPickerDemoViewController.h"
#import "CTAssetsPickerController.h"

@interface CTAssetsPickerDemoViewController ()<CTAssetsPickerControllerDelegate, UINavigationControllerDelegate>{
    UIButton *_openAlbumButton;
}

@end

@implementation CTAssetsPickerDemoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.title = @"CTAssetsPickerDemo";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _openAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openAlbumButton setTitle:@"从相册选择照片" forState:UIControlStateNormal];
    [_openAlbumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_openAlbumButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _openAlbumButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_openAlbumButton addTarget:self action:@selector(clickOpenAlbumButton:) forControlEvents:UIControlEventTouchUpInside];
    _openAlbumButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGFloat _openAlbumButton_W = 120.0;
    CGFloat _openAlbumButton_H = 30.0;
    CGFloat _openAlbumButton_Y = 30.0 + (NSInteger)(self.navigationController.navigationBar.isTranslucent) * 64.0;
    CGFloat _openAlbumButton_X = (self.view.bounds.size.width - _openAlbumButton_W) * 0.5;
    
    _openAlbumButton.frame = CGRectMake(_openAlbumButton_X, _openAlbumButton_Y, _openAlbumButton_W, _openAlbumButton_H);
    [self.view addSubview:_openAlbumButton];
}

- (void)clickOpenAlbumButton:(UIButton *)button{
    CTAssetsPickerController *assetsPickerController = [[CTAssetsPickerController alloc] initWithAssetsType:CTAssetsPickerControllerAssetsTypeAllAsset];
    assetsPickerController.delegate = self;
    assetsPickerController.enableMaximumCount = 9;
    [self presentViewController:assetsPickerController animated:YES completion:NULL];
}

- (void)assetsPickerController:(CTAssetsPickerController *)assetsPickerController didFinishPickingAssets:(NSArray *)assets assetsType:(CTAssetsPickerControllerAssetsType)assetsType{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerController:didFinishPickingAssets:assetsType:)));
    switch (assetsType) {
        case CTAssetsPickerControllerAssetsTypePhoto:{
            
        }
            break;
        case CTAssetsPickerControllerAssetsTypeVideo:{
            
        }
            break;
        case CTAssetsPickerControllerAssetsTypeAllAsset:{
            
        }
            break;
        default:
            break;
    }
}

- (void)assetsPickerController:(CTAssetsPickerController *)assetsPickerController didDeselectAsset:(ALAsset *)asset{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerController:didDeselectAsset:)));
}

- (void)assetsPickerController:(CTAssetsPickerController *)assetsPickerController didSelectAsset:(ALAsset *)asset{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerController:didSelectAsset:)));
}

- (void)assetsPickerController:(CTAssetsPickerController *)assetsPickerController didSelectCountReachedEnableMaximumCount:(NSUInteger)enableMaximumCount{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerController:didSelectCountReachedEnableMaximumCount:)));
}

- (void)assetsPickerController:(CTAssetsPickerController *)assetsPickerController didSelectCountUnderEnableMinimumCount:(NSUInteger)enableMinimumCount{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerController:didSelectCountUnderEnableMinimumCount:)));
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)assetsPickerController{
    NSLog(@"%@", NSStringFromSelector(@selector(assetsPickerControllerDidCancel:)));
}

@end
