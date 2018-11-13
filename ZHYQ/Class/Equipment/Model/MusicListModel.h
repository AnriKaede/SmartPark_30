//
//  MusicListModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MusicListModel : BaseModel
/*
 {
 attr = 1;
 fid = 906;
 length = 348;
 name = "Kalimba.mp3";
 }
 */

@property (nonatomic,strong) NSNumber *attr;
@property (nonatomic,strong) NSNumber *fid;
@property (nonatomic,strong) NSNumber *length;
@property (nonatomic,strong) NSString *name;

@property (nonatomic,assign) BOOL isPlay;

@end
