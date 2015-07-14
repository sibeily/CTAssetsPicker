//
//  CTAssetsPickerAssetData.m
//  CTAssetsPicker
//
//  Created by wshaolin on 15/7/9.
//  Copyright (c) 2015年 神州锐达（北京）科技有限公司. All rights reserved.
//

#import "CTAssetsPickerAssetData.h"

@implementation CTAssetsPickerAssetData

- (instancetype)initWithAsset:(ALAsset *)asset{
    if(self = [super init]){
        _asset = asset;
        NSString *assetType = [_asset valueForProperty:ALAssetPropertyType];
        if([assetType isEqualToString:ALAssetTypePhoto]){
            _assetDataType = CTAssetsPickerAssetDataTypePhoto;
        }else if([assetType isEqualToString:ALAssetTypeVideo]){
            _assetDataType = CTAssetsPickerAssetDataTypeVideo;
            NSTimeInterval timeInterval = [[_asset valueForProperty:ALAssetPropertyDuration] floatValue];
            _videoDuration = [self videoDurationStringWithValue:(int)lroundf(timeInterval)];
        }else if([assetType isEqualToString:ALAssetTypeUnknown]){
            _assetDataType = CTAssetsPickerAssetDataTypeUnknown;
        }
        _selected = NO;
    }
    return self;
}

- (NSString *)videoDurationStringWithValue:(int)value{
    int hour = 0;
    int minute = 0;
    int second = value;
    
    int unit = 60;
    if(second >= unit){
        minute = value / unit;
        second = value % unit;
    }
    
    if (minute >= unit) {
        hour = minute / unit;
        minute = minute % unit;
    }
    
    if(hour > 0){
        return [NSString stringWithFormat:@"%d:%.2d:%.2d", hour, minute, second];
    }else{
        return [NSString stringWithFormat:@"%d:%.2d", minute, second];
    }
}

@end
