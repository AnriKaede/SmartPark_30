//
//  BgMusicMapModel.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface BgMusicMapModel : BaseModel

@property (nonatomic,copy) NSString *LATITUDE;
@property (nonatomic,copy) NSString *LAYER_A;
@property (nonatomic,copy) NSString *DEVICE_ADDR;
@property (nonatomic,copy) NSString *LAYER_C;

@property (nonatomic,copy) NSString *LAYER_B;
@property (nonatomic,copy) NSString *DEVICE_TYPE;
@property (nonatomic,copy) NSString *DEVICE_NAME;
@property (nonatomic,copy) NSString *POINT_TYPE;

@property (nonatomic,copy) NSString *TAGID;
@property (nonatomic,copy) NSString *LONGITUDE;
@property (nonatomic,strong) NSString *LAYER_ID;
@property (nonatomic,copy) NSString *DEVICE_ID;

@property (nonatomic,copy) NSString *MUSIC_STATUS;

@property (nonatomic,assign) BOOL isOpen;

@property (nonatomic,copy) NSString *currentMusic;

@end
