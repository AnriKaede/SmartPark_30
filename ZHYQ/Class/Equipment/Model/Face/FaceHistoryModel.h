//
//  FaceHistoryModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/29.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FaceHistoryModel : BaseModel

/*
{
    "agentType": "PC",
    "createTime": 1543460234000,
    "faceInfo": "data:image/jpeg;base64,/9j/4AAQSkZJRgA… ",
    "status": "1",
    "userId": "1",
    "uuid": "123568"
}
*/

@property (nonatomic,copy) NSString *agentType;
@property (nonatomic,strong) NSNumber *createTime;
@property (nonatomic,copy) NSString *faceInfo;
@property (nonatomic,copy) NSString *status;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *uuid;

@property (nonatomic,assign) BOOL isSelDelete;

@end

NS_ASSUME_NONNULL_END
