//
//  BgMusicModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/24.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface BgMusicModel : BaseModel
/*
 {
 areaId = 1001;
 areaName = "\U5ba4\U5185\U97f3\U4e50";
 fault = 2;
 musicId = 1001;
 musicName = "\U6697\U9999";
 off = 4;
 on = 6;
 total = 12;
 }
 */

@property (nonatomic,copy) NSString *areaId;
@property (nonatomic,copy) NSString *fault;
@property (nonatomic,copy) NSString *on;
@property (nonatomic,copy) NSString *musicName;
@property (nonatomic,copy) NSString *off;
@property (nonatomic,copy) NSString *musicId;
@property (nonatomic,copy) NSString *total;
@property (nonatomic,copy) NSString *areaName;

@end
