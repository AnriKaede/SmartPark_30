//
//  AddBatchViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/28.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "RootViewController.h"

@protocol FaceBatchCompleteDelegate <NSObject>

- (void)faceBatchComplete:(NSArray *)wranModels;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AddBatchViewController : RootViewController

@property (nonatomic,copy) NSArray *selImgs;
@property (nonatomic,assign) id<FaceBatchCompleteDelegate> faceBatchCompleteDelegate;

@end

NS_ASSUME_NONNULL_END
