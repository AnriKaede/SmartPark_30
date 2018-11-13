//
//  MealCountCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealDayModel.h"

typedef enum {
    FilterDay = 0,
    FilterWeek,
    FilterMonth
}FilterDateStyle;

typedef enum {
    DayLinkRatio = 0,
    WeekLinkRatio,
    MonthLinkRatio
}LinkRatio;

@protocol VisDateFilterDelegate <NSObject>

- (void)filterDelegate:(FilterDateStyle)filterDateStyle;

- (void)didSelectChartLineIndex:(NSInteger)selIndex;

@end

@interface MealCountCell : UITableViewCell

@property (nonatomic,copy) NSArray *xRollerData;
@property (nonatomic,copy) NSArray *numData;
@property (nonatomic,copy) NSArray *costData;

@property (nonatomic, retain) MealDayModel *mealDayModel;

@property (nonatomic,assign) id<VisDateFilterDelegate> filterDelegate;

@property (nonatomic,assign) LinkRatio linkRatio;

@end
