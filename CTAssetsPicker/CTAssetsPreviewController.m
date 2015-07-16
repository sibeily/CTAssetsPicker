//
//  CTAssetsPreviewController.m
//  CTAssetsPickerDemo
//
//  Created by wshaolin on 15/7/13.
//  Copyright (c) 2015年 神州锐达（北京）科技有限公司. All rights reserved.
//

#import "CTAssetsPreviewController.h"
#import "CTAssetsViewToolBar.h"
#import "CTAssetView.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPickerAssetData.h"
#import "CTAssetsToolBarButtonItem.h"

#define CTAssetsPreviewControllerViewPadding 10.0
#define CTAssetsPreviewControllerViewTagOffset 1000

static inline NSInteger CTAssetsPreviewControllerViewIndexFromAssetView(CTAssetView *assetView){
    return assetView.tag - CTAssetsPreviewControllerViewTagOffset;
}

@interface CTAssetsPreviewController ()<UIScrollViewDelegate, CTAssetsViewToolBarDelegate, CTAssetViewDelegate>{
    UIScrollView *_assetScrollView;
    
    NSMutableSet *_visibleAssetViews;
    NSMutableSet *_reusableAssetViews;
    
    CTAssetsViewToolBar *_toolBar;
    CTAssetsToolBarButtonItem *_selectBarButtonItem;
    BOOL _initialStatusBarHidden;
    BOOL _initialNavigationBarTranslucent;
    
    __weak CTAssetsPickerController *_assetsPickerController;
}

@end

@implementation CTAssetsPreviewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.title = NSLocalizedString(@"预览", nil);
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        _toolBar = [[CTAssetsViewToolBar alloc] init];
        _toolBar.hiddenPreviewItem = YES;
        _toolBar.delegate = self;
        _toolBar.translucent = YES;
        
        _selectBarButtonItem = [CTAssetsToolBarButtonItem buttonWithType:UIButtonTypeCustom];
        _selectBarButtonItem.enableHighlighted = NO;
        [_selectBarButtonItem setImage:[UIImage imageNamed:@"CTAssetsPicker.bundle/CTAssetsPickerSelectButtonNormal"] forState:UIControlStateNormal];
        [_selectBarButtonItem setImage:[UIImage imageNamed:@"CTAssetsPicker.bundle/CTAssetsPickerSelectButtonSelected"] forState:UIControlStateSelected];
        _selectBarButtonItem.backgroundColor = [UIColor clearColor];
        [_selectBarButtonItem addTarget:self action:@selector(didClickSelectBarButtonItem:)];
        _selectBarButtonItem.frame = CGRectMake(0, 0, 40.0, 40.0);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = _initialNavigationBarTranslucent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_selectBarButtonItem];
    
    _assetsPickerController = (CTAssetsPickerController *)self.navigationController;
    _initialStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    _initialNavigationBarTranslucent = self.navigationController.navigationBar.isTranslucent;
    _toolBar.enableMaximumCount = _assetsPickerController.enableMaximumCount;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    CGRect assetScrollViewFrame = self.view.bounds;
    assetScrollViewFrame.origin.x -= CTAssetsPreviewControllerViewPadding;
    assetScrollViewFrame.size.width += (2 * CTAssetsPreviewControllerViewPadding);
    _assetScrollView = [[UIScrollView alloc] initWithFrame:assetScrollViewFrame];
    
    _assetScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _assetScrollView.pagingEnabled = YES;
    _assetScrollView.delegate = self;
    _assetScrollView.showsHorizontalScrollIndicator = NO;
    _assetScrollView.showsVerticalScrollIndicator = NO;
    _assetScrollView.backgroundColor = [UIColor clearColor];
    _assetScrollView.contentSize = CGSizeMake(assetScrollViewFrame.size.width * _assetDataArray.count, 0);
    _assetScrollView.contentOffset = CGPointMake(_currentAssetIndex * assetScrollViewFrame.size.width, 0);
    [self.view addSubview:_assetScrollView];
    
    _toolBar.translucent = self.navigationController.navigationBar.isTranslucent;
    _toolBar.frame = CGRectMake(0, self.view.bounds.size.height - _toolBar.frame.size.height, 0, 0);
    [self.view addSubview:_toolBar];
    [self showAsset];
}

- (void)didClickSelectBarButtonItem:(CTAssetsToolBarButtonItem *)barButtonItem{
    BOOL shouldSelection = YES;
    if(!barButtonItem.isSelected){
        if(_assetsPickerController.enableMaximumCount > 0 && _seletedCount == _assetsPickerController.enableMaximumCount){
            if(_assetsPickerController.delegate && [_assetsPickerController.delegate respondsToSelector:@selector(assetsPickerController:didSelectCountReachedEnableMaximumCount:)]){
                [_assetsPickerController.delegate assetsPickerController:_assetsPickerController didSelectCountReachedEnableMaximumCount:_assetsPickerController.enableMaximumCount];
            }
            shouldSelection = NO;
        }
    }
    
    if(shouldSelection){
        if(_currentAssetIndex < _assetDataArray.count){
            barButtonItem.selected = !barButtonItem.isSelected;
            CTAssetsPickerAssetData *assetData = _assetDataArray[_currentAssetIndex];
            assetData.selected = barButtonItem.isSelected;
            if(self.delegate && [self.delegate respondsToSelector:@selector(assetsPreviewController:didSelectedAssetData:)]){
                [self.delegate assetsPreviewController:self didSelectedAssetData:assetData];
            }
        }
    }
}

- (void)setSeletedCount:(NSInteger)seletedCount{
    _seletedCount = seletedCount;
    _toolBar.selectedCount = seletedCount;
}

- (void)setAssetDataArray:(NSArray *)assetDataArray{
    _assetDataArray = assetDataArray;
    
    if(assetDataArray.count > 1){
        _visibleAssetViews = [NSMutableSet set];
        _reusableAssetViews = [NSMutableSet set];
    }
}

- (void)showAsset{
    if (_assetDataArray.count == 1) {
        [self showAssetViewAtIndex:0];
    }else{
        CGRect visibleBounds = _assetScrollView.bounds;
        NSInteger firstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds) + CTAssetsPreviewControllerViewPadding * 2) / CGRectGetWidth(visibleBounds));
        NSInteger lastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds) - CTAssetsPreviewControllerViewPadding * 2 - 1) / CGRectGetWidth(visibleBounds));
        if (firstIndex < 0){
            firstIndex = 0;
        }
        if (firstIndex >= _assetDataArray.count){
            firstIndex = _assetDataArray.count - 1;
        }
        if (lastIndex < 0){
            lastIndex = 0;
        }
        if (lastIndex >= _assetDataArray.count){
            lastIndex = _assetDataArray.count - 1;
        }
        
        // 回收不再显示的View
        for (CTAssetView *assetView in _visibleAssetViews) {
            NSInteger assetIndex = CTAssetsPreviewControllerViewIndexFromAssetView(assetView);
            if (assetIndex < firstIndex || assetIndex > lastIndex) {
                [_reusableAssetViews addObject:assetView];
                [assetView removeFromSuperview];
            }
        }
    
        [_visibleAssetViews minusSet:_reusableAssetViews];
        while (_reusableAssetViews.count > 2) {
            [_reusableAssetViews removeObject:[_reusableAssetViews anyObject]];
        }
        
        for (NSUInteger index = firstIndex; index <= lastIndex; index ++) {
            if (![self isShowingAssetViewAtIndex:index]) {
                [self showAssetViewAtIndex:index];
            }
        }
    }
    _currentAssetIndex = (NSUInteger)lroundf(_assetScrollView.contentOffset.x / _assetScrollView.frame.size.width);
    if(_currentAssetIndex >= _assetDataArray.count){
        _currentAssetIndex = _assetDataArray.count - 1;
    }
    CTAssetsPickerAssetData *assetData = _assetDataArray[_currentAssetIndex];
    _selectBarButtonItem.selected = assetData.isSelected;
}

- (BOOL)isShowingAssetViewAtIndex:(NSUInteger)index {
    for (CTAssetView *assetView in _visibleAssetViews) {
        if (CTAssetsPreviewControllerViewIndexFromAssetView(assetView) == index) {
            return YES;
        }
    }
    return  NO;
}

- (CTAssetView *)dequeueReusableAssetView{
    CTAssetView *assetView = [_reusableAssetViews anyObject];
    if (assetView != nil) {
        [_reusableAssetViews removeObject:assetView];
    }
    return assetView;
}

- (void)showAssetViewAtIndex:(NSUInteger)index{
    CTAssetView *assetView = [self dequeueReusableAssetView];
    if (assetView == nil) {
        assetView = [[CTAssetView alloc] init];
        assetView.customDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _assetScrollView.bounds;
    CGRect assetViewFrame = bounds;
    assetViewFrame.size.width -= (2 * CTAssetsPreviewControllerViewPadding);
    assetViewFrame.origin.x = (bounds.size.width * index) + CTAssetsPreviewControllerViewPadding;
    assetView.tag = CTAssetsPreviewControllerViewTagOffset + index;
    assetView.frame = assetViewFrame;
    assetView.assetData = _assetDataArray[index];
    
    [_visibleAssetViews addObject:assetView];
    [_assetScrollView addSubview:assetView];
}

- (void)assetViewDidSingleTouch:(CTAssetView *)assetView{
    BOOL animated = YES;
    if(self.navigationController.navigationBar.hidden){
        [_toolBar show:animated];
        [[UIApplication sharedApplication] setStatusBarHidden:_initialStatusBarHidden withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }else{
        [_toolBar hide:animated];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_assetDataArray.count > 1){
        [self showAsset];
    }
}

- (void)assetsViewToolBarDidCompleted:(CTAssetsViewToolBar *)assetsViewToolBar{
    if(self.delegate && [self.delegate respondsToSelector:@selector(assetsPreviewControllerDidCompleted:)]){
        [self.delegate assetsPreviewControllerDidCompleted:self];
    }
}

@end
