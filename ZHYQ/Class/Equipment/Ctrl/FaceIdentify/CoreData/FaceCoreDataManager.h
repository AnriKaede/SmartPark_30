//
//  FaceCoreDataManager.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/14.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceCoreDataManager : NSObject

+ (instancetype)shareManager;

// 创建NSManagedObject
- (id)createMO:(NSString *)entityName;

// 保存
- (void)save:(NSManagedObject *)mo;

// 查询
- (NSArray *)query:(NSString *)entityName predicate:(NSPredicate *)predicate;

// 修改
- (void)update:(NSManagedObject *)mo;

// 删除
- (void)remove:(NSManagedObject *)mo;

@end

NS_ASSUME_NONNULL_END
