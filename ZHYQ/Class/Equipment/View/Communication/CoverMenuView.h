//
//  CoverMenuView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/21.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommnncCoverModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CoverMenuDelegate <NSObject>

- (void)queryCover:(CommnncCoverModel *)coverModel;

@end

@interface CoverMenuView : UIView

@property (nonatomic,assign) id<CoverMenuDelegate> coverMenuDelegate;

@property (nonatomic,retain) CommnncCoverModel *coverModel;

- (void)reloadMenu;

@end

NS_ASSUME_NONNULL_END
