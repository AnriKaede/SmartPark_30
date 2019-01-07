//
//  CheckTaskHomeViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    UnActionTask = 0,
    CompleteTask
}HomeCheckTaskType;

NS_ASSUME_NONNULL_BEGIN

@interface CheckTaskHomeViewController : RootViewController

@property (nonatomic,assign) HomeCheckTaskType checkTaskType;

@end

NS_ASSUME_NONNULL_END
