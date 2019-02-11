//
//  MonitorTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MonitorTimeViewController.h"
#import "PlaybackManager.h"
#import "WSDatePickerView.h"
#import "DHVideoWnd.h"
#import "DHHudPrecess.h"

#import "TimeRangeCell.h"

#define timeRange @"timeRange"
#define timeIndex @"timeIndex"

@interface MonitorTimeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UIView *_headerView;
    UICollectionView *_timeCollectView;
    
    NSMutableArray *_allTimeData;
    NSMutableArray *_timeData;
}
@end

@implementation MonitorTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allTimeData = @[].mutableCopy;
    _timeData = @[].mutableCopy;
    
    [self _initView];
    
    [self _initCollectView];
    
    [self _queryData];
}
- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    self.title = @"选择监控时段";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 头部视图
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
    // 添加渐变色
    [NavGradient viewAddGradient:_headerView];
    _headerView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:_headerView];
    
    CGFloat itemWidth = KScreenWidth/4 - 10;
    NSArray *titles = @[@"凌晨时段", @"上午时段", @"下午时段", @"晚上 时段"];
    for (int i=0; i<4; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 2000 + i;
        button.frame = CGRectMake(10*i + itemWidth*i + 5, 15, itemWidth, 30);
        button.backgroundColor = [UIColor colorWithHexString:@"#33A4FB"];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selTimeRange:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:button];
    }
}

- (void)_initCollectView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(KScreenWidth/2, 70);
    _timeCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _headerView.bottom + 5, KScreenWidth, KScreenHeight - _headerView.bottom - 5 - 64) collectionViewLayout:layout];
    _timeCollectView.delegate = self;
    _timeCollectView.dataSource = self;
    _timeCollectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_timeCollectView];
    
    [_timeCollectView registerNib:[UINib nibWithNibName:@"TimeRangeCell" bundle:nil] forCellWithReuseIdentifier:@"TimeRangeCell"];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 选择时间区间
- (void)selTimeRange:(UIButton *)selButton {
    for (int i=0; i<4; i++) {
        UIButton *button = [_headerView viewWithTag:2000 + i];
        if(button == selButton){
            [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1 "] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
        }else {
            button.backgroundColor = [UIColor colorWithHexString:@"#33A4FB"];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    [self rangeByTime:selButton.tag - 2000];
}

- (void)rangeByTime:(NSInteger)type {
    // type: 0 凌晨，1：上午，2：中午，3：下午
    NSString *rangeBegin;
    NSString *rangeEnd;
    switch (type) {
        case 0:
            {
                rangeBegin = @"00:00";
                rangeEnd = @"06:00";
                break;
            }
        case 1:
        {
            rangeBegin = @"06:00";
            rangeEnd = @"12:00";
            break;
        }
        case 2:
        {
            rangeBegin = @"12:00";
            rangeEnd = @"18:00";
            break;
        }
        case 3:
        {
            rangeBegin = @"18:00";
            rangeEnd = @"24:00";
            break;
        }
            
        default:
            break;
    }
    
    [_timeData removeAllObjects];
    [_allTimeData enumerateObjectsUsingBlock:^(NSDictionary *rangeDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileTimeRange = rangeDic[timeRange];
        NSArray *ranges = [fileTimeRange componentsSeparatedByString:@"-"];
        if(ranges.count > 1){
            NSString *beginTime = ranges.firstObject;
            NSString *endTime = ranges.lastObject;
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"HH:mm"];
            
            NSDate *standBeginDate = [format dateFromString:rangeBegin];
            NSDate *standEndDate = [format dateFromString:rangeEnd];
            
            NSDate *beginDate = [format dateFromString:beginTime];
            NSDate *endDate = [format dateFromString:endTime];
            
            BOOL isRange = [self judgeTimeByStartAndEnd:rangeBegin withExpireTime:rangeEnd withSelTime:endTime];
            if(isRange){
                [_timeData addObject:rangeDic];
            }
        }
    }];
    
    [_timeCollectView reloadData];
}

// 当前时间是否在时间段内 (忽略年月日)
- (BOOL)judgeTimeByStartAndEnd:(NSString *)startTime withExpireTime:(NSString *)expireTime withSelTime:(NSString *)selTime {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *today = [dateFormat dateFromString:selTime];
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && ([today compare:expire] == NSOrderedAscending || [today compare:expire] == NSOrderedSame)) {
        return YES;
    }
    return NO;
}

#pragma mark 查询大华sdk 是当天时间段
- (void)_queryData {
    // 初始化查询
    [[PlaybackManager sharedInstance]initPlaybackManager];
    
    [PlaybackManager sharedInstance].recordResourceValue = DPSDK_CORE_PB_RECSOURCE_DEVICE;
    [PlaybackManager sharedInstance].recordTypeValue = 0;
    [PlaybackManager sharedInstance].isPlayBackByFile = YES;
    
    [self onBtnQueryRecord];
    
}

#pragma mark 查询方法
- (void)onBtnQueryRecord {
    
    [[DHHudPrecess sharedInstance]showWaiting:@""
                               WhileExecuting:@selector(threadQueryRecord)
                                     onTarget:self
                                   withObject:Nil
                                     animated:NO
                                       atView:KEYWINDOW];
}

#pragma mark 查询
- (void)threadQueryRecord
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    
//    NSTimeZone* localzone = [NSTimeZone localTimeZone];
//    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    [dateFormatter setTimeZone:GTMzone];
    
    [PlaybackManager sharedInstance].isStartTime = YES;
    NSString *beginStr = [_queryDate stringByAppendingString:@" 00:00"];
    [PlaybackManager sharedInstance].isStartTime = NO;
    NSString *endStr = [_queryDate stringByAppendingString:@" 23:59"];
    
    NSDate *queryDate =[dateFormatter dateFromString:beginStr];
    NSDate *laterDate =[dateFormatter dateFromString:endStr];
    
    int nError = [[PlaybackManager sharedInstance]queryRecordByStart:queryDate withEnd:laterDate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([PlaybackManager sharedInstance].isFileExisted == NO) {
            [self showHint:@"该时间段内没有录像"];
        }else if (0 != nError) {
            [self showHint:@"查询失败"];
        }
        // 查询成功
        if(nError == 0) {
            _allTimeData = [[PlaybackManager sharedInstance]queryFileList];
        }
    });
    
}

#pragma mark collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _timeData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TimeRangeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TimeRangeCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    NSDictionary *timeRangeDic = _timeData[indexPath.row];
    cell.cellTimeRange = timeRangeDic[timeRange];
    NSNumber *indexNum = timeRangeDic[timeIndex];
    cell.cellTimeIndex = indexNum.integerValue;
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(KScreenWidth/2, 70);
}

//footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(0, 0);
    return size;
}

//设置每个item的UIEdgeInsets
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(10.0, 10.0*wScale, 10.0, 10.0*wScale);
//}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *timeRangeDic = _timeData[indexPath.row];
    NSNumber *indexNum = timeRangeDic[timeIndex];
    if(_timeDelegate){
        [_timeDelegate selTime:indexNum.integerValue withRange:timeRangeDic[timeRange]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
