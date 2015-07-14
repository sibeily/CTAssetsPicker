//
//  CTAssetsPickerController.m
//  CTAssetsPicker
//
//  Created by wshaolin on 15/7/9.
//  Copyright (c) 2015年 神州锐达（北京）科技有限公司. All rights reserved.
//

#import "CTAssetsPickerController.h"
#import "CTAssetsGroupViewController.h"

@interface CTAssetsPickerController (){
    CTAssetsGroupViewController *_assetsGroupViewController;
}

@end

@implementation CTAssetsPickerController

@dynamic delegate;

- (instancetype)init{
    CTAssetsGroupViewController *assetsGroupViewController = [[CTAssetsGroupViewController alloc] init];
    if(self = [super initWithRootViewController:assetsGroupViewController]){
        _assetsType = CTAssetsPickerControllerAssetsTypePhoto;
        _assetsFilter = [ALAssetsFilter allPhotos];
        _finishDismissViewController = YES;
        _assetsGroupViewController = assetsGroupViewController;
        
        self.navigationBar.hidden = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    return self;
}

- (instancetype)initWithAssetsType:(CTAssetsPickerControllerAssetsType)assetsType{
    CTAssetsGroupViewController *assetsGroupViewController = [[CTAssetsGroupViewController alloc] init];
    if(self = [super initWithRootViewController:assetsGroupViewController]){
        _assetsType = assetsType;
        _finishDismissViewController = YES;
        _assetsGroupViewController = assetsGroupViewController;
        
        switch (assetsType) {
            case CTAssetsPickerControllerAssetsTypePhoto:{
                _assetsFilter = [ALAssetsFilter allPhotos];
            }
                break;
            case CTAssetsPickerControllerAssetsTypeVideo:{
                _assetsFilter = [ALAssetsFilter allVideos];
            }
                break;
            case CTAssetsPickerControllerAssetsTypeAllAsset:{
                _assetsFilter = [ALAssetsFilter allAssets];
            }
                break;
            default:
                break;
        }
        
        self.navigationBar.hidden = NO;
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    return self;
}

- (NSArray *)selectedAssets{
    return _assetsGroupViewController.selectedAssets;
}

- (void)deselectAssetAtIndex:(NSUInteger)index{
    [_assetsGroupViewController deselectAssetAtIndex:index];
}

- (void)setToolbarItemBackgroundColor:(UIColor *)toolbarItemBackgroundColor{
    [_assetsGroupViewController setToolbarItemBackgroundColor:toolbarItemBackgroundColor];
}

- (void)setToolbarItemFontColor:(UIColor *)toolbarItemFontColor{
    [_assetsGroupViewController setToolbarItemFontColor:toolbarItemFontColor];
}

@end
