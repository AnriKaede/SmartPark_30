//
//  DistributorFilterView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "DistributorFilterView.h"
#import "CFDropDownMenuView.h"
#import "YQInDoorPointMapView.h"
#import "BuildView.h"

@interface DistributorFilterView()<CFDropDownMenuViewDelegate, DidSelInMapPopDelegate, BuildDelegate>
@property (nonatomic,strong) NSMutableArray *distributorDataArr;
@property (nonatomic,strong) NSMutableArray *graphData;
@end

@implementation DistributorFilterView
{
    CFDropDownMenuView *_dropDownMenuView;
    YQInDoorPointMapView *indoorView;
    BuildView *_buildView;
}

-(NSMutableArray *)wifiDataArr
{
    if (_distributorDataArr == nil) {
        _distributorDataArr = [NSMutableArray array];
    }
    return _distributorDataArr;
}

-(NSMutableArray *)graphData
{
    if (_graphData == nil) {
        _graphData = [NSMutableArray array];
    }
    return _graphData;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self loadData];
        [self _initView];
        [self loadBuildView];
        [self _initPointMapView];
    }
    return self;
}

- (void)loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/peiDianData/queryPDline",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSLog(@"%@", responseObject);
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)_initView {
    _dropDownMenuView = [[CFDropDownMenuView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 45)];
    
    /**
     *  stateConfigDict 属性 格式 详见CFDropDownMenuView.h文件
     *  可不传  使用默认样式  /   也可自定义样式
     */
    _dropDownMenuView.dataSourceArr = @[
                                       @[@"研发楼"],
                                       @[@"1F", @"2F", @"3F", @"4F", @"5F", @"6F", @"7F", @"8F", @"9F", @"10F"],
                                       @[@"照明动力", @"公共照明"]
                                       ].mutableCopy;
    
    _dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"研发楼",@"建筑", @"区域", @"配电箱", nil];
    // 设置代理
    _dropDownMenuView.delegate = self;
    
    // 下拉列表 起始y
    _dropDownMenuView.startY = CGRectGetMaxY(_dropDownMenuView.frame);

    // 添加到父视图中
    [self addSubview:_dropDownMenuView];
    
    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark 筛选协议 回调
- (void)dropDownMenuView:(CFDropDownMenuView *)dropDownMenuView clickOnCurrentButtonWithTitle:(NSString *)currentTitle andCurrentTitleArray:(NSArray *)currentTitleArray withIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        _buildView.hidden = NO;
        indoorView.hidden = YES;
//        [_buildView showBuild];
        [_buildView showFloor];
    }
//    else if(indexPath.section == 1){
//        _buildView.hidden = NO;
//        indoorView.hidden = YES;
//        [_buildView showFloor];
//    }
    else if(indexPath.section == 1){
        _buildView.hidden = YES;
        indoorView.hidden = NO;
        [indoorView updateMapImg:[NSString stringWithFormat:@"yfl%ldf", indexPath.row + 1]];
    }else if(indexPath.section == 2){
        _buildView.hidden = YES;
        indoorView.hidden = NO;
    }
    
}

#pragma mark 加载建筑楼层显示图
- (void)loadBuildView {
    _buildView = [[BuildView alloc] initWithFrame:CGRectMake(0, 45, KScreenWidth, self.height - 45)];
    _buildView.buildDelegate = self;
    [self addSubview:_buildView];
//    [_buildView showBuild];
    [_buildView showFloor];
}

#pragma mark 加载点位图
-(void)_initPointMapView
{
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:[NSString stringWithFormat:@"%@",@"yfl1f"] Frame:CGRectMake(0, 45, KScreenWidth, self.height - 45)];
    indoorView.hidden = YES;
    indoorView.selInMapDelegate = self;
    [self addSubview:indoorView];
}
- (void)selInMapWithId:(NSString *)identity {
    NSLog(@"%@", identity);
}

#pragma mark 点击建筑协议
- (void)buildLeft {
//    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    [_buildView showFloor];
}
- (void)buildRight {
//    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    [_buildView showFloor];
}

- (void)buildFloor:(NSInteger)index {
    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    
    _buildView.hidden = YES;
    indoorView.hidden = NO;
    [indoorView updateMapImg:[NSString stringWithFormat:@"yfl%ldf", index + 1]];
}

@end
