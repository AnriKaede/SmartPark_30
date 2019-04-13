//
//  MonitorTimeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MonitorTimeViewController.h"
#import "WSDatePickerView.h"

#import "TimeRangeCell.h"

#import "DHHudPrecess.h"
#import "ZComBoxView.h"
#import "DHPlaybackManager.h"
#import "DHDataCenter.h"

#define timeRange @"timeRange"
#define timeIndex @"timeIndex"

@interface MonitorTimeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UIView *_headerView;
    UICollectionView *_timeCollectView;
    
    NSMutableArray *_allTimeData;
    NSMutableArray *_timeData;
    
    /*
     RecordSource_all,///<所有录像 All
     RecordSource_platform,///< 云录像 Platform
     RecordSource_device,///< 设备录像 Device
     */
    RecordSource recordSourceType;  // 录像类型
}
@end

@implementation MonitorTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _allTimeData = @[].mutableCopy;
    _timeData = @[].mutableCopy;
    
    recordSourceType = RecordSource_all;
    
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
    [_allTimeData enumerateObjectsUsingBlock:^(DSSRecordInfo *recordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger startTime = recordInfo.startTime;
        NSInteger endTime = recordInfo.endTime;
        
        NSLog(@"%ld %ld", startTime, endTime);
        
        NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:startTime];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
        
        BOOL isRange = [self judgeTimeByStartAndEnd:[self dateWithHM:rangeBegin] withExpireTime:[self dateWithHM:rangeEnd] withSelBeginTime:beginDate withSelEndTime:endDate];
        if(isRange){
            [_timeData addObject:recordInfo];
        }
    }];
    
    [_timeCollectView reloadData];
}

// 当前时间是否在时间段内 (忽略年月日)
- (BOOL)judgeTimeByStartAndEnd:(NSDate *)start withExpireTime:(NSDate *)expire withSelBeginTime:(NSDate *)selStartDate withSelEndTime:(NSDate *)selEndDate {
    if(([selStartDate compare:start] == NSOrderedDescending || [selStartDate compare:start] == NSOrderedSame) && ([selEndDate compare:expire] == NSOrderedAscending || [selEndDate compare:expire] == NSOrderedSame)){
        return YES;
    }
    
    return NO;
}

#pragma mark 查询大华sdk 是当天时间段
- (void)_queryData {
    
    NSString *beginStr = [_queryDate stringByAppendingString:@" 00:00"];
    NSString *endStr = [_queryDate stringByAppendingString:@" 23:59"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
//    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    [dateFormatter setTimeZone:GTMzone];
    
    NSDate *queryDate =[dateFormatter dateFromString:beginStr];
    NSDate *laterDate =[dateFormatter dateFromString:endStr];
    
    NSError *error = nil;
    TreeNode *channelNode = [DHDataCenter sharedInstance].selectNode;
    NSString *channelid = ((DSSChannelInfo *)channelNode.content).channelid;
    
    ((DSSChannelInfo *)channelNode.content).channelid = channelid;
    
    NSArray *recordInfos = [[DHPlaybackManager sharedInstance] queryRecord:channelid begin:queryDate end:laterDate source:recordSourceType error:&error];
    [_allTimeData removeAllObjects];
    [_allTimeData addObjectsFromArray:recordInfos];
    
    if (error.code != 0){
        NSLog(@"query failed");
        [self showHint:@"查询失败"];
    }
    if (recordInfos.count == 0) {
        NSLog(@"no records");
        [self showHint:@"该时间段内没有录像"];
    }
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
    DSSRecordInfo *recordInfo = _timeData[indexPath.row];
    cell.cellTimeRange = [self timeRangeWithDate:recordInfo.startTime withEnd:recordInfo.endTime];
//    NSNumber *indexNum = timeRangeDic[timeIndex];
//    cell.cellTimeIndex = indexNum.integerValue;
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
    DSSRecordInfo *recordInfo = _timeData[indexPath.row];
    if(_timeDelegate){
        [_timeDelegate selTime:0 withRange:[self timeRangeWithDate:recordInfo.startTime withEnd:recordInfo.endTime] withDSSRecordInfo:recordInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)timeRangeWithDate:(NSInteger)startTime withEnd:(NSInteger)endTime {
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
//    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    [dateFormat setTimeZone:GTMzone];
    NSString *comStr = [NSString stringWithFormat:@"%@-%@", [dateFormat stringFromDate:beginDate], [dateFormat stringFromDate:endDate]];
    return comStr;
}

- (NSDate *)dateWithHM:(NSString *)hm {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
//    [dateFormat setTimeZone:GTMzone];
    NSString *nowDay = [_queryDate stringByAppendingFormat:@" %@",hm];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormat dateFromString:nowDay];
}

@end
