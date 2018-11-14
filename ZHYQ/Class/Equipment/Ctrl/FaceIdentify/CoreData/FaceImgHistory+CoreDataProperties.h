//
//  FaceImgHistory+CoreDataProperties.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//
//

#import "FaceImgHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FaceImgHistory (CoreDataProperties)

+ (NSFetchRequest<FaceImgHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *selTime;
@property (nullable, nonatomic, copy) NSString *imgFilePath;

@end

NS_ASSUME_NONNULL_END
