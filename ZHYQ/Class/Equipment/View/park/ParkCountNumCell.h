//
//  ParkCountNumCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkDayCountModel.h"

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

@protocol DateFilterDelegate <NSObject>

- (void)filterDelegate:(FilterDateStyle)filterDateStyle;

- (void)didSelectChartLineIndex:(NSInteger)selIndex;

@end

@interface ParkCountNumCell : UITableViewCell

@property (nonatomic, copy) NSArray *snapData;
@property (nonatomic, copy) NSArray *carNumData;

@property (nonatomic, copy) NSArray *xRollerData;   // x轴坐标，不为空取 snapData reportOccurHour

@property (nonatomic, retain) ParkDayCountModel *dayCountModel;

@property (nonatomic,assign) id<DateFilterDelegate> filterDelegate;

@property (nonatomic,assign) LinkRatio linkRatio;

@end
