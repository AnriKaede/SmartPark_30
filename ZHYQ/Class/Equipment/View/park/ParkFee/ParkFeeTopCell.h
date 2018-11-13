//
//  ParkFeeTopCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FilterDay = 0,
    FilterWeek,
    FilterMonth
}FilterDateStyle;

@protocol ParkFeeDateFilterDelegate <NSObject>

- (void)filterDelegate:(FilterDateStyle)filterDateStyle;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ParkFeeTopCell : UITableViewCell

@property (nonatomic,assign) id<ParkFeeDateFilterDelegate> filterDelegate;

@end

NS_ASSUME_NONNULL_END
