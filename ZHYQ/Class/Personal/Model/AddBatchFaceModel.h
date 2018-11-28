//
//  AddBatchFaceModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/28.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddBatchFaceModel : BaseModel

@property (nonatomic,retain) UIImage *faceImage;
@property (nonatomic,copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
