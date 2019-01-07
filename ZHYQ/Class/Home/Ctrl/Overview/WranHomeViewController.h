//
//  WranHomeViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/7.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RootViewController.h"

typedef enum {
    EqWran = 0,
    ApWran,
    OtherWran
}HomeWranType;

NS_ASSUME_NONNULL_BEGIN

@interface WranHomeViewController : RootViewController

@property (nonatomic,assign) HomeWranType wranType;

@end

NS_ASSUME_NONNULL_END
