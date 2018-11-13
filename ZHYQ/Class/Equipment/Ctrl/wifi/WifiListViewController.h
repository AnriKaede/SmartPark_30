//
//  WifiListViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <WMPageController.h>

@interface WifiListViewController : WMPageController

@property (nonatomic,strong) NSMutableArray *titleArr;

-(instancetype)initWithTitleArr:(NSMutableArray *)titleArr;

@end
