//
//  BgMusicListViewController.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <WMPageController/WMPageController.h>

@interface BgMusicListViewController : WMPageController

@property (nonatomic,strong) NSMutableArray *titleArr;
@property (nonatomic,strong) NSMutableArray *musicDataArr;

-(instancetype)initWithTitleArr:(NSMutableArray *)titleArr;

@end
