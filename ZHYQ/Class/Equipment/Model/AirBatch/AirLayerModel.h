//
//  AirLayerModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/27.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "BaseModel.h"

@interface AirLayerModel : BaseModel

/*
{
    "layerId": "11",
    "layerName": "研发十楼",
    "rooms": []
}
 */

@property (nonatomic,copy) NSString *layerId;
@property (nonatomic,copy) NSString *layerName;
@property (nonatomic,copy) NSArray *rooms;

@property (nonatomic,assign) BOOL isSelect;

@end
