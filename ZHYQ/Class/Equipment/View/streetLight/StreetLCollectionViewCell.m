//
//  StreetLCollectionViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/12/5.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "StreetLCollectionViewCell.h"
#import "YQInDoorPointMapView.h"
#import "SubDeviceModel.h"

@interface StreetLCollectionViewCell()<DidSelInMapPopDelegate>
{
    YQInDoorPointMapView *indoorView;
    UILabel *titleLab;
    NSMutableArray *graphData;
}

//@property (nonatomic,strong) NSMutableArray *grapArr;

@end

@implementation StreetLCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    indoorView.scrollEnabled = NO;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initView];
        graphData = @[].mutableCopy;
//        _grapArr = [NSMutableArray array];
    }
    return self;
}

-(void)_initView
{
    titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, KScreenWidth, 25)];
    titleLab.font = [UIFont systemFontOfSize:20];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor blackColor];
    [self.contentView addSubview:titleLab];
    
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"stLight" Frame:CGRectMake(KScreenWidth/2-(260.0*hScale/2), titleLab.bottom+5, 260*hScale, 447*hScale) withScale:1];
    indoorView.selInMapDelegate = self;
    [self.contentView addSubview:indoorView];
}

- (void)selInMapWithId:(NSString *)identity
{
    NSInteger selIndex = identity.integerValue - 100;
    if(_model.grapArr.count > selIndex){
        SubDeviceModel *deviceModel = _model.grapArr[selIndex];
        if(_streetDeviceDelegate && [_streetDeviceDelegate respondsToSelector:@selector(selDevice:)]){
            [_streetDeviceDelegate selDevice:deviceModel];
        }
    }
}

-(void)setModel:(StreetLightModel *)model
{
    _model = model;
    
    titleLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
    if (indoorView) {
        [indoorView removeFromSuperview];
        indoorView.delegate = nil;
        indoorView = nil;
        indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"stLight" Frame:CGRectMake(0, titleLab.bottom+5, KScreenWidth, 447*hScale) withScale:1];
        indoorView.isMinScaleWithHeight = YES;
        indoorView.selInMapDelegate = self;
        [self.contentView addSubview:indoorView];
        
    }
    indoorView.streetLightGraphData = model.graphData;
    indoorView.streetLightArr = model.grapArr;
}

//-(void)_loadSonEquip:(NSString *)deviceId
//{
//    NSString *urlStr = [NSString stringWithFormat:@"%@/common/getSubDeviceList?deviceId=%@",Main_Url,deviceId];
//    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
//        [graphData removeAllObjects];
//        [_grapArr removeAllObjects];
//        if ([responseObject[@"code"] isEqualToString:@"1"]) {
//            //            DLog(@"%@",responseObject);
//            NSArray *arr = responseObject[@"responseData"];
//            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                SubDeviceModel *model = [[SubDeviceModel alloc] initWithDataDic:obj];
//                [graphData addObject:[NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C]];
//                [_grapArr addObject:model];
//            }];
//            
//            indoorView.streetLightGraphData = graphData;
//            indoorView.streetLightArr = _grapArr;
//            
//        }
//    } failure:^(NSError *error) {
//        DLog(@"%@",error);
//    }];
//}

//-(void)setGrapArr:(NSMutableArray *)grapArr
//{
//    _grapArr = grapArr;
//
//    [grapArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        SubDeviceModel *model = (SubDeviceModel *)obj;
//        [graphData addObject:[NSString stringWithFormat:@"%@,%@,%@",model.LAYER_A,model.LAYER_B,model.LAYER_C]];
//    }];
//
//    indoorView.streetLightArr = grapArr;
//    indoorView.streetLightGraphData = graphData;
//
//}

@end
