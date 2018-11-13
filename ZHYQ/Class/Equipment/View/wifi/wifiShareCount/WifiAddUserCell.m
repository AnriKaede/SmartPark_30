//
//  WifiAddUserCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiAddUserCell.h"
#import "AAChartView.h"
#import "WifiNewUserModel.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface WifiAddUserCell()
{
    UIScrollView *_chartScrollView;
    __weak IBOutlet UILabel *allUserLabel;
    
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@end

@implementation WifiAddUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _createSnapView];
}

#pragma mark 折线图
- (void)_createSnapView {
    // 创建折线背景scrollView
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 214)];
    _chartScrollView.bounces = NO;
    [self.contentView insertSubview:_chartScrollView atIndex:0];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, _chartScrollView.height)];
    self.snapChartView.contentHeight = _chartScrollView.height - 20;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor whiteColor];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .legendEnabledSet(false)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"人数")
                 .dataSet(@[@5,@6,@3,@10,@6,@8,@3,@6]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

- (void)setUserData:(NSArray *)userData {
    userData = [self sortByX:userData];
    
    _userData = userData;
    
    NSMutableArray *countAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    __block NSInteger allUser = 0;
    [userData enumerateObjectsUsingBlock:^(WifiNewUserModel *timeModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [timeArr addObject:[NSString stringWithFormat:@"%@", [self timeFormatt:timeModel.addNewUser]]];
        [countAry addObject:[NSNumber numberWithString:timeModel.userCount]];
        
        allUser += timeModel.userCount.integerValue;
    }];
    
    [self refreshSnap:countAry withTime:timeArr];
    
    allUserLabel.text = [NSString stringWithFormat:@"%ld人", allUser];
}
- (NSArray *)sortByX:(NSArray *)data {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray *sortData = data.mutableCopy;
    [sortData enumerateObjectsUsingBlock:^(WifiNewUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i=idx; i<data.count; i++) {
            WifiNewUserModel *iSpeedModel = sortData[i];
            
            NSDate *idxDate = [dateFormat dateFromString:userModel.addNewUser];
            NSDate *iDate = [dateFormat dateFromString:iSpeedModel.addNewUser];
            if([idxDate compare:iDate] == NSOrderedDescending){
                [sortData exchangeObjectAtIndex:idx withObjectAtIndex:i];
                userModel = iSpeedModel;
            }
        }
    }];
    return sortData;
}
- (NSString *)timeFormatt:(NSString *)time {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:time];
    
    NSDateFormatter *inputDateFormat = [[NSDateFormatter alloc] init];
    [inputDateFormat setDateFormat:@"MM-dd"];
    NSString *dateStr = [inputDateFormat stringFromDate:date];
    
    return dateStr;
}

- (void)refreshSnap:(NSArray *)countAry withTime:(NSArray *)timeArr {
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, _chartScrollView.height)];
        self.snapChartView.contentHeight = _chartScrollView.height - 20;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor whiteColor];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#000000")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#000000")    // y轴坐标值颜色
    .legendEnabledSet(false)
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"人数")
                 .dataSet(countAry),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#1B82D1"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
}

@end
