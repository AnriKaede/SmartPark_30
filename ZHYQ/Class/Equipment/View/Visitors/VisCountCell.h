//
//  VisCountCell.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisCountNumModel.h"

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

@interface VisCountCell : UITableViewCell

@property (nonatomic, copy) NSArray *countData;

@property (nonatomic, retain) VisCountNumModel *visCountNumModel;

@property (nonatomic, retain) NSArray *xRollerData;
@property (nonatomic, retain) NSArray *snapData;
@property (nonatomic, retain) NSArray *postData;

@property (nonatomic,assign) id<VisDateFilterDelegate> filterDelegate;

@property (nonatomic,assign) LinkRatio linkRatio;

@end
