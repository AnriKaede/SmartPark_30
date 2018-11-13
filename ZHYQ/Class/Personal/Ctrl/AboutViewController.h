//
//  AboutViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "RootViewController.h"

@class PublicModel;

@interface AboutViewController : RootViewController

@property (nonatomic,strong) PublicModel *model;

@property (nonatomic,copy) NSString *isNeedUpdate;

@end
