//
//  PFFilterContentView.h
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkFeeFilterModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PopContentDelegate <NSObject>

-(void)resetBtnCallBackAction;
-(void)completeBtnCallBackAction:(ParkFeeFilterModel *)prkFeeFilterModel;

@end

@interface PFFilterContentView : UIView

@property (nonatomic,weak) id<PopContentDelegate> delegate;
@property (nonatomic,retain) ParkFeeFilterModel *parkFeeFilterModel;

@end

NS_ASSUME_NONNULL_END
