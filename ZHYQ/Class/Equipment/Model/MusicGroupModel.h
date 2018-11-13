//
//  MusicGroupModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/25.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface MusicGroupModel : BaseModel

/*
{
    "gid": 1,                           ----分组Id
    "name": "研发楼卫生间",            ----分组名称
    "status": 0,  ​ ----当前设备状态
    "t_count": 2,                       ----分组包含的终端数量
    "tids": [                           ----终端设备Id
             2,
             3
             ],
    "vol": 40                          ----当前音量
},
{
    "gid": 2,
    "musicname": "薛之谦 - 刚刚好",    ----当前播放音乐名
    "name": "研发楼电梯内",
    "status": 1,
    "t_count": 3,
    "tids": [
             1,
             2,
             3
             ],
    "vol": 20
}
 */

@property (nonatomic, strong) NSNumber *gid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *t_count;
@property (nonatomic, copy) NSArray *tids;

@property (nonatomic, copy) NSString *musicname;
@property (nonatomic, assign) NSNumber *status; // 当状态是1时 musicname才有值
@property (nonatomic, strong) NSNumber *vol;    // 音量

@end
