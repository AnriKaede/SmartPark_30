//
//  FaceImgHistory+CoreDataProperties.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//
//

#import "FaceImgHistory+CoreDataProperties.h"

@implementation FaceImgHistory (CoreDataProperties)

+ (NSFetchRequest<FaceImgHistory *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FaceImgHistory"];
}

@dynamic selTime;
@dynamic imgFilePath;

@end
