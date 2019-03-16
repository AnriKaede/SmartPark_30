//
//  IMUserQuery.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/3/16.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMUserQuery : NSObject

+ (IMUserQuery *)shaerInstance;

- (void)loadServerUserData;

- (NSString *)queryNickWithId:(NSString *)userId;

- (void)updateUserData:(NSMutableArray *)data;

- (NSMutableArray *)IMUserData;

@end

NS_ASSUME_NONNULL_END
