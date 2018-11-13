//
//  StreetLCollectionViewCell.h
//  ZHYQ
//
//  Created by 焦平 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreetLightModel.h"
#import "SubDeviceModel.h"

@protocol StreetSelDeviceDelegate <NSObject>

- (void)selDevice:(SubDeviceModel *)deviceModel;

@end

@interface StreetLCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) StreetLightModel *model;

@property (nonatomic,assign) id<StreetSelDeviceDelegate> streetDeviceDelegate;

@end
