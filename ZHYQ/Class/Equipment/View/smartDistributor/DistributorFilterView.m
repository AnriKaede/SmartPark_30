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
#import "DistributorFloorModel.h"
#import "DistributorLineModel.h"

@interface DistributorFilterView()<CFDropDownMenuViewDelegate, DidSelInMapPopDelegate, BuildDelegate>
@property (nonatomic,strong) NSMutableArray *distributorDataArr;

@property (nonatomic,strong) NSMutableArray *floorDataArr;
@property (nonatomic,strong) NSMutableArray *lineDataArr;
@property (nonatomic,strong) NSMutableArray *lineGraphData;
@end

@implementation DistributorFilterView
{
    CFDropDownMenuView *_dropDownMenuView;
    YQInDoorPointMapView *indoorView;
    BuildView *_buildView;
    
    DistributorFloorModel *_selFloorModel;
}

-(NSMutableArray *)distributorDataArr
{
    if (_distributorDataArr == nil) {
        _distributorDataArr = [NSMutableArray array];
    }
    return _distributorDataArr;
}
- (NSMutableArray *)floorDataArr {
    if (_floorDataArr == nil) {
        _floorDataArr = [NSMutableArray array];
    }
    return _floorDataArr;
}
- (NSMutableArray *)lineDataArr {
    if (_lineDataArr == nil) {
        _lineDataArr = [NSMutableArray array];
    }
    return _lineDataArr;
}
-(NSMutableArray *)lineGraphData
{
    if (_lineGraphData == nil) {
        _lineGraphData = [NSMutableArray array];
    }
    return _lineGraphData;
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
    NSString *urlStr = [NSString stringWithFormat:@"%@/peiDianData/queryPeiDianInfo",Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"params":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self.distributorDataArr removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DistributorFloorModel *model = [[DistributorFloorModel alloc] initWithDataDic:obj];
                [self.distributorDataArr addObject:model];
            }];
            [self refreshDropDownView];
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
    // 设置代理
    _dropDownMenuView.delegate = self;
    
    // 下拉列表 起始y
    _dropDownMenuView.startY = CGRectGetMaxY(_dropDownMenuView.frame);

    // 添加到父视图中
    [self addSubview:_dropDownMenuView];
    
    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)refreshDropDownView {
//    [@[@"研发楼"],@[@"1F", @"2F", @"3F", @"4F", @"5F", @"6F", @"7F", @"8F", @"9F", @"10F"],@[@"照明动力", @"公共照明"]]
    
    [self.floorDataArr removeAllObjects];
    [self.lineDataArr removeAllObjects];
    
    [self.distributorDataArr enumerateObjectsUsingBlock:^(DistributorFloorModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.floorDataArr addObject:model.LAYERNAME];
    }];
    
    _dropDownMenuView.dataSourceArr = @[@[@"研发楼"],self.floorDataArr, self.lineDataArr].mutableCopy;
    _dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"研发楼", @"区域", @"线路", nil];
    
    [_dropDownMenuView selIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    _buildView.floorData = self.distributorDataArr;
}

#pragma mark 筛选协议 回调
- (void)dropDownMenuView:(CFDropDownMenuView *)dropDownMenuView clickOnCurrentButtonWithTitle:(NSString *)currentTitle andCurrentTitleArray:(NSArray *)currentTitleArray withIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        _buildView.hidden = NO;
        indoorView.hidden = YES;
        [_buildView showFloor];
    }else if(indexPath.section == 1){
        _buildView.hidden = YES;
        indoorView.hidden = NO;
        DistributorDeviceModel *model = self.distributorDataArr[indexPath.row];
        [indoorView updateMapImg:[NSString stringWithFormat:@"yfl%ldf", model.LAYERID.integerValue - 1]];
        
        [self selFloor:indexPath.row];
    }else if(indexPath.section == 2){
        _buildView.hidden = YES;
        indoorView.hidden = NO;
        
        [self selLine:indexPath.row];
    }
    
}

- (void)selFloor:(NSInteger)floorIndex {
    if(self.distributorDataArr.count > floorIndex){
        [self.lineDataArr removeAllObjects];
        DistributorFloorModel *floorModel = self.distributorDataArr[floorIndex];
        _selFloorModel = floorModel;
        [floorModel.deviceInfoList enumerateObjectsUsingBlock:^(DistributorDeviceModel *lineModel, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.lineDataArr addObject:lineModel.DEVICENAME];
        }];
        
//        _dropDownMenuView.dataSourceArr = @[@[@"研发楼"],self.floorDataArr, self.lineDataArr].mutableCopy;
//        _dropDownMenuView.defaulTitleArray = [NSArray arrayWithObjects:@"研发楼", @"区域", @"线路", nil];
    }
}

- (void)selLine:(NSInteger)index {
    if(_selFloorModel.deviceInfoList.count > index){
        DistributorDeviceModel *lineModel = _selFloorModel.deviceInfoList[index];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/peiDianData/queryPDline",Main_Url];
        NSMutableDictionary *param = @{}.mutableCopy;
        [param setObject:lineModel.DEVICEID forKey:@"deviceId"];
        NSString *jsonParam = [Utils convertToJsonData:param];
        NSDictionary *params = @{@"params":jsonParam};
        
        [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
            if ([responseObject[@"code"] isEqualToString:@"1"]) {
                NSArray *responseData = responseObject[@"responseData"];
                [self.lineGraphData removeAllObjects];
                [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DistributorLineModel *model = [[DistributorLineModel alloc] initWithDataDic:obj];
                    [self.lineGraphData addObject:model];
                }];
                if(lineModel.DEGREE != nil && ![lineModel.DEGREE isKindOfClass:[NSNull class]]){
                    [self drawLineInMap:lineModel.DEGREE.integerValue];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)drawLineInMap:(NSInteger)eleve {
    // 1良好2正常3轻度危险4危险5高度危险
    UIColor *eleveColor = [UIColor blackColor];
    switch (eleve) {
        case 1:
            eleveColor = [UIColor colorWithHexString:@"#9AC97F"];
            break;
            
        case 2:
            eleveColor = CNavBgColor;
            break;
            
        case 3:
            eleveColor = [UIColor colorWithHexString:@"#CEBD57"];
            break;
            
        case 4:
            eleveColor = [UIColor colorWithHexString:@"#FFC13B"];
            break;
            
        case 5:
            eleveColor = [UIColor redColor];
            break;
            
        default:
            break;
    }
    [indoorView drawLineMap:self.lineGraphData withColor:eleveColor];
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
    
    DistributorDeviceModel *model = self.distributorDataArr[index];
    [indoorView updateMapImg:[NSString stringWithFormat:@"yfl%ldf", model.LAYERID.integerValue - 1]];
    
    [self selFloor:index];
}

@end
