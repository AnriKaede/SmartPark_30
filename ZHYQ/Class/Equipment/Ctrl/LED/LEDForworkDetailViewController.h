//
//  LEDForworkDetailViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "LEDFormworkModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LEDForworkDetailViewController : RootViewController
@property (nonatomic,assign) BOOL isEdit;   // 是否是编辑
@property (nonatomic,retain) LEDFormworkModel *formworkModel;
@end

NS_ASSUME_NONNULL_END
