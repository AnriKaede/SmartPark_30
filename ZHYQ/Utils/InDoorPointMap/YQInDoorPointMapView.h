//
//  YQInDoorPointMapView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQIndoorMapTransfer.h"
#import "SmallMapView.h"
#import "DownParkMdel.h"

@protocol DidSelInMapPopDelegate <NSObject>

- (void)selInMapWithId:(NSString *)identity;

@end

@interface YQInDoorPointMapView : UIScrollView<UIScrollViewDelegate, DidSelPopDelegate>

@property(nonatomic,strong)UIImageView *mapView;
@property (nonatomic, assign) id<DidSelInMapPopDelegate> selInMapDelegate;

@property (nonatomic,assign) BOOL isLayCoord;   // 是否采用a b c坐标(不是经纬度)

@property (nonatomic, copy) NSArray *graphData;

@property (nonatomic, copy) NSArray *streetLightGraphData;

@property (nonatomic, strong) NSMutableArray *wifiModelArr;

@property (nonatomic, strong) NSMutableArray *doorModelArr;

@property (nonatomic, strong) NSMutableArray *cameraModelArr;

@property (nonatomic, strong) NSMutableArray *bgMusicArr;

@property (nonatomic, strong) NSMutableArray *parkLightArr;

@property (nonatomic, strong) NSMutableArray *airConArr;

@property (nonatomic, strong) NSMutableArray *streetLightArr;


@property (nonatomic, strong) NSMutableArray *parkDownArr;  // 车库点位图数组

// 路灯数据
@property (nonatomic, strong) NSMutableArray *streetLightMapArr;

// LED数据
@property (nonatomic, strong) NSMutableArray *LEDMapArr;

// 小地图
@property (nonatomic, strong) SmallMapView *smallMapView;

// 设置缩放比例依据(宽/高)
@property (nonatomic, assign) BOOL isMinScaleWithHeight;

-(id)initWithIndoorMapImageName:(NSString*)indoorMap Frame:(CGRect)frame withScale:(CGFloat)scale;

-(id)initWithIndoorMapImageName:(NSString*)indoorMap Frame:(CGRect)frame;

- (void)updateMapImg:(NSString *)imgName;

// 修改车库点位图图标
- (void)updateCarIcon:(DownParkMdel *)downParkMdel withIndex:(NSInteger)index;
- (void)normalCarIcon:(DownParkMdel *)downParkMdel withIndex:(NSInteger)index;

@end
