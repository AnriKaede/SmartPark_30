//
//  SnapCountCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "SnapCountCell.h"
#import "AAChartView.h"

#import "VisotorListViewController.h"

#define PageLineWidth (KScreenWidth - 60)/7

@interface SnapCountCell()
{
    UIScrollView *_chartScrollView;
}
@property (nonatomic, strong) AAChartModel *snapChartModel;
@property (nonatomic, strong) AAChartView  *snapChartView;
@end

@implementation SnapCountCell
{
    __weak IBOutlet UIView *_snapBgView;
    
    __weak IBOutlet UILabel *_visAllLabel;
    
    __weak IBOutlet UILabel *_visLeaveLabel;
    __weak IBOutlet UILabel *_visUnLevelLabel;
    
    __weak IBOutlet UIView *_allCountView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _crateSnapView];
    
    UITapGestureRecognizer *listTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listAction)];
    [_allCountView addGestureRecognizer:listTap];
}
- (void)listAction {
    VisotorListViewController *visitorVC = [[VisotorListViewController alloc] init];
    [[self viewController].navigationController pushViewController:visitorVC animated:YES];
}

- (void)_crateSnapView {
    _chartScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, KScreenWidth, 275)];
    _chartScrollView.bounces = NO;
    //    _chartScrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, 0);
    [_snapBgView addSubview:_chartScrollView];
    
    self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 275)];
    self.snapChartView.contentHeight = 260;
    self.snapChartView.isClearBackgroundColor = YES;
    self.snapChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_chartScrollView addSubview:self.snapChartView];
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[@"0",@"3",@"6",@"9", @"12",@"15",@"18",@"21",@"24"])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"访客人数")
                 .dataSet(@[@45,@88,@49,@43,@65,@56,@47,@28,@49]),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#FFC921"];
    
    [self.snapChartView aa_drawChartWithChartModel:_snapChartModel];
}

- (void)setAllVis:(NSString *)allVis {
    _allVis = allVis;
    
    if(allVis != nil && ![allVis isKindOfClass:[NSNull class]]){
        _visAllLabel.text = [NSString stringWithFormat:@"总访客人数: %@人", allVis];
    }
}

- (void)setLevVis:(NSString *)levVis {
    _levVis = levVis;
    
    if(_levVis != nil && ![_levVis isKindOfClass:[NSNull class]]){
        _visLeaveLabel.text = [NSString stringWithFormat:@"%@人", levVis];
    }
}

- (void)setUnLevVis:(NSString *)unLevVis {
    _unLevVis = unLevVis;
    
    if(unLevVis != nil && ![unLevVis isKindOfClass:[NSNull class]]){
        _visUnLevelLabel.text = [NSString stringWithFormat:@"%@人", unLevVis];
    }
}

- (void)setTodayData:(NSArray *)todayData {
    _todayData = todayData;
    
    [self refreshSnap];
}

#pragma mark 刷新折线图
- (void)refreshSnap {
    
    NSMutableArray *countAry = @[].mutableCopy;
    NSMutableArray *timeArr = @[].mutableCopy;
    [_todayData enumerateObjectsUsingBlock:^(NSDictionary *timeDic, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [timeArr addObject:[NSString stringWithFormat:@"%@", timeDic[@"hour"]]];
        if([timeDic[@"count"] isKindOfClass:[NSString class]]){
            [countAry addObject:[NSNumber numberWithString:timeDic[@"count"]]];
        }else {
            [countAry addObject:timeDic[@"count"]];
        }
        
    }];
    
    if(timeArr.count > 7){
        // 大于7列 滑动
        CGFloat snapChartWidth = 60 + PageLineWidth*timeArr.count;
        _chartScrollView.contentSize = CGSizeMake(snapChartWidth, 0);
        [_chartScrollView setContentOffset:CGPointMake(_chartScrollView.contentSize.width - KScreenWidth, 0) animated:YES];
        
        self.snapChartView = nil;
        [_snapChartView removeFromSuperview];
        
        self.snapChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 0, snapChartWidth, 275)];
        self.snapChartView.contentHeight = 260;
        self.snapChartView.isClearBackgroundColor = YES;
        self.snapChartView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [_chartScrollView addSubview:self.snapChartView];
        
    }
    
    self.snapChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeLine)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(timeArr)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"访客人数")
                 .dataSet(countAry),
                 ]
               )
    ;
    
    self.snapChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.snapChartModel.symbol = AAChartSymbolTypeCircle;
    self.snapChartModel.colorsTheme = @[@"#FFC921"];
    
    [self.snapChartView aa_drawChartWithChartModel:self.snapChartModel];
    //    [_parkTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
