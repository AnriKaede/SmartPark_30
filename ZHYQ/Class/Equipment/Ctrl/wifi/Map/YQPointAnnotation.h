//
//  YQPointAnnotation.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "WifiMapModel.h"
#import "BgMusicMapModel.h"
#import "MonitorMapModel.h"

@interface YQPointAnnotation : MAPointAnnotation

@property (nonatomic, copy) NSString *number;

@property (nonatomic, strong) UIImage *image;

//Code...这里可以扩展很多属性，来给大头针视图提供数据支持。

@property (nonatomic,copy) NSString *status;

@property (nonatomic, retain) WifiMapModel *wifiMapModel;

@property (nonatomic, retain) BgMusicMapModel *bgMusicMapModel;

@property (nonatomic, retain) MonitorMapModel *monitorMapModel;

@end
