//
//  ParkFeeFilterView.h
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkFeeFilterModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ParkFeeFaliterPopViewDelegate <NSObject>

-(void)resetCallBackAction;
-(void)completeCallBackAction:(ParkFeeFilterModel *)parkFeeFilterModel;
-(void)hideShowAction;

@end

@interface ParkFeeFilterView : UIView

/**
 *  显示属性选择视图
 *
 *  @param view 要在哪个视图中显示
 */
- (void)showInView:(UIView *)view;

/**
 *  属性视图的消失
 */
- (void)removeView;

@property (nonatomic,assign) BOOL isShow;
@property (nonatomic,weak) id<ParkFeeFaliterPopViewDelegate> delegate;

@property (nonatomic,copy) NSString *visitName;
@property (nonatomic,copy) NSString *visitCarNum;
@property (nonatomic,copy) NSString *arriveTime;
@property (nonatomic,copy) NSString *leaveTime;

@end

NS_ASSUME_NONNULL_END
