//
//  LogFilterViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"

@interface LogFilterViewController : RootViewController

/** 点击已选回调 */
@property (nonatomic , copy) void(^sureClickBlock)(NSArray *selectArray);

@end
