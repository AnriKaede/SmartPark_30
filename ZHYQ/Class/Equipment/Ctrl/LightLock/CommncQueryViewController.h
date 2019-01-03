//
//  CommncQueryViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "RootViewController.h"
#import "CommnncLockModel.h"
#import "CommnncCoverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommncQueryViewController : RootViewController

@property (nonatomic,retain) CommnncLockModel *lockModel;
@property (nonatomic,retain) CommnncCoverModel *coverModel;

@end

NS_ASSUME_NONNULL_END
