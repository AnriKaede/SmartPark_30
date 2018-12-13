//
//  YQInDoorPointMapView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQInDoorPointMapView.h"
#import "InDoorWifiModel.h"
#import "DoorModel.h"
#import "InDoorMonitorMapModel.h"
#import "InDoorBgMusicMapModel.h"
#import "ParkLightModel.h"
#import "AirConditionModel.h"
#import "DownParkMdel.h"
#import "StreetLightModel.h"

#import "SubDeviceModel.h"
#import "LedListModel.h"

#import "DistributorLineModel.h"

#define scal 0.2

#define PointImgWidth 50

@interface YQInDoorPointMapView ()
{
    CGFloat _scale;
    CAShapeLayer *m_shapeLayer;
}
@end

@implementation YQInDoorPointMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)initWithIndoorMapImageName:(NSString*)indoorMap Frame:(CGRect)frame withScale:(CGFloat)scale
{
    if (self=[super init]) {
        
        _scale = scale;
        
        self = [self initWithIndoorMapImageName:indoorMap Frame:frame];
        
    }
    return self;
}

-(id)initWithIndoorMapImageName:(NSString*)indoorMap Frame:(CGRect)frame;
{
    if (self=[super init]) {
        
        self.bounces = NO;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.frame = frame;
        
        UIImage *map = [UIImage imageNamed:indoorMap];
        if(map == nil){
            map = [UIImage imageNamed:@"empty"];
        }
        _mapView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, map.size.width, map.size.height)];
        _mapView.contentMode = UIViewContentModeScaleAspectFit;
        _mapView.backgroundColor = [UIColor clearColor];
        _mapView.image = map;
        _mapView.userInteractionEnabled = YES;
        [self addSubview:_mapView];
        
        //双击
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTapGesture setNumberOfTapsRequired:2];
        [_mapView addGestureRecognizer:doubleTapGesture];
        
        CGFloat minScale = self.frame.size.width/_mapView.frame.size.width;
        [self setMinimumZoomScale:minScale];
        [self setZoomScale:minScale];
        
        CGFloat newScale;
        if (_scale != 0) {
            newScale = self.zoomScale*_scale;
        }else{
            newScale = self.zoomScale*2.5;
        }

        CGRect zoonRect = [self zoomRectForScale:newScale withCenter:CGPointMake(map.size.width/2, map.size.height/2)];
        [self zoomToRect:zoonRect animated:NO];
        
    }
    return self;
}

- (SmallMapView *)smallMapView {
    if(_smallMapView == nil){
        // 小地图视图
        _smallMapView = [SmallMapView new];
        _smallMapView.backgroundColor = [UIColor redColor];
        //        _smallMapView.touchMoveDelegate = self;
        _smallMapView = [_smallMapView initWithUIScrollView:self frame:CGRectMake(0, self.bottom - self.height * scal, self.width * scal, self.height * scal)];
    }
    return _smallMapView;
}

- (void)setIsMinScaleWithHeight:(BOOL)isMinScaleWithHeight {
    _isMinScaleWithHeight = isMinScaleWithHeight;
    
    if(isMinScaleWithHeight){
        if(_mapView.image != nil){
            CGFloat minScale = self.frame.size.height/_mapView.image.size.height;
            [self setMinimumZoomScale:minScale];
            [self setZoomScale:minScale];
        }
    }
}

#pragma mark 修改地图背景图
- (void)updateMapImg:(NSString *)imgName {
    UIImage *map = [UIImage imageNamed:imgName];
    
    _mapView.image = map;
    
    if(m_shapeLayer != nil){
        [m_shapeLayer removeFromSuperlayer];
    }
}

#pragma ScrollView 协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!_smallMapView.isTouchMove){
        [_smallMapView scrollViewDidScroll:scrollView];
    }
}

- (void)setGraphData:(NSArray *)graphData {
    _graphData = graphData;
    
    [graphData enumerateObjectsUsingBlock:^(NSString *graphStr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *pointAry = [graphStr componentsSeparatedByString:@","];
        if(pointAry == nil || pointAry.count < 2){
            return ;
        }
        NSString *x = pointAry[0];
        NSString *y = pointAry[1];
        
        UIImageView *videoImgView;
        UIImageView *bottomImgView;
        if(_isLayCoord){
            videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x.floatValue, y.floatValue, PointImgWidth, PointImgWidth)];
            bottomImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x.floatValue, y.floatValue, PointImgWidth, PointImgWidth)];
        }else {
            // 楼层图高度
            if(_mapView.image != nil){            
                CGFloat imgHeight = _mapView.image.size.height;
                videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x.floatValue, imgHeight - y.floatValue, PointImgWidth, PointImgWidth)];
                bottomImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x.floatValue, imgHeight - y.floatValue, PointImgWidth, PointImgWidth)];
            }
        }
        
//        UIImageView *videoImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x.floatValue/2.4f, y.floatValue/2.4f, 20, 20)];
//        videoImgView.image = [UIImage imageNamed:@"wifi_normal"];
        videoImgView.tag = 100+idx;
        bottomImgView.tag = 200+idx;
        bottomImgView.hidden = YES;
        videoImgView.userInteractionEnabled = YES;
        bottomImgView.userInteractionEnabled = YES;
        [_mapView addSubview:videoImgView];
        [_mapView insertSubview:bottomImgView belowSubview:videoImgView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [videoImgView addGestureRecognizer:tap];
//        [bottomImgView addGestureRecognizer:tap];
    }];
}

- (void)setStreetLightGraphData:(NSArray *)streetLightGraphData {
    _streetLightGraphData = streetLightGraphData;
    
    [streetLightGraphData enumerateObjectsUsingBlock:^(NSString *graphStr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *pointAry = [graphStr componentsSeparatedByString:@","];
        NSString *x = pointAry[0];
        NSString *y = pointAry[1];
        
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 130)];
        pointView.center = CGPointMake([x floatValue], [y floatValue]);
        pointView.tag = 100 + idx;
        [_mapView addSubview:pointView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [pointView addGestureRecognizer:tap];
        
        UIImageView *lightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 130, 130)];
        lightImgView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        lightImgView.tag = 1000 + idx;
        lightImgView.userInteractionEnabled = YES;
        [pointView addSubview:lightImgView];
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, lightImgView.bottom - 40, 160, 60)];
        lable.tag = 2000+idx;
        lable.textColor = [UIColor colorWithHexString:@"#34BFFF"];
        lable.font = [UIFont systemFontOfSize:25];
        lable.numberOfLines = 2;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.userInteractionEnabled = YES;
        [pointView addSubview:lable];
        
        /*
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        lable.center = CGPointMake([x floatValue], [y floatValue]);
        lable.tag = 100 + idx;
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:13];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.userInteractionEnabled = YES;
        [_mapView addSubview:lable];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [lable addGestureRecognizer:tap];
         */
    }];
}

// 路灯挂载子设备地图
-(void)setStreetLightArr:(NSMutableArray *)streetLightArr
{
    _streetLightArr = streetLightArr;
    
    [streetLightArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SubDeviceModel *model = (SubDeviceModel *)obj;
        UIView *pointView = [_mapView viewWithTag:100+idx];
        UIImageView *imgView = [pointView viewWithTag:1000+idx];
        // 添加动画
        [self addViewBaseAnim:imgView];
        
        UILabel *label = [pointView viewWithTag:2000+idx];
        
        label.text = model.DEVICE_NAME;
        
        /*
        UILabel *lab = [_mapView viewWithTag:100+idx];
        CGSize size = [model.DEVICE_NAME sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        lab.size = CGSizeMake(size.width+5, size.height+10);
        lab.layer.cornerRadius = 3;
        lab.clipsToBounds = YES;
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont systemFontOfSize:13];
        lab.backgroundColor = [UIColor orangeColor];
        lab.text = model.DEVICE_NAME;
         */
    }];
}

// 路灯杆数据
- (void)setStreetLightMapArr:(NSMutableArray *)streetLightMapArr {
    _streetLightMapArr = streetLightMapArr;
    
    [streetLightMapArr enumerateObjectsUsingBlock:^(StreetLightModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        // 添加动画
        [self addViewBaseAnim:imageView];
        
//        UIImageView *bottomImgView = [_mapView viewWithTag:200+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
//        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 65, 200);
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 130, 130);
//        bottomImgView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        if([model.DEVICE_TYPE isEqualToString:@"55-2"]){
            // 莲花灯
//            imageView.image = [UIImage imageNamed:@"street_lamp_map_flower"];
            imageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
//            bottomImgView.frame = CGRectMake(bottomImgView.left-32, bottomImgView.top + 135, 130, 130);
        }else {
//            imageView.image = [UIImage imageNamed:@"street_lamp_map_nor"];
            imageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
//            bottomImgView.frame = CGRectMake(bottomImgView.left-44, bottomImgView.top + 135, 130, 130);
        }
    }];
}

-(void)setWifiModelArr:(NSMutableArray *)wifiModelArr
{
    _wifiModelArr = wifiModelArr;
    [wifiModelArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        InDoorWifiModel *model = (InDoorWifiModel *)obj;
        if ([model.WIFI_STATUS isEqualToString:@"1"]||[model.WIFI_STATUS isEqualToString:@"2"]) {
            imageView.image = [UIImage imageNamed:@"wifi_normal"];
        }else{
            imageView.image = [UIImage imageNamed:@"wifi_error"];
        }
    }];
}

- (void)setDoorModelArr:(NSMutableArray *)doorModelArr {
    _doorModelArr = doorModelArr;
    
    [doorModelArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        DoorModel *model = (DoorModel *)obj;
        // 闸机用透明图片
        if ([model.DEVICE_TYPE isEqualToString:@"4-1"]) {
            imageView.image = [UIImage imageNamed:@""];
        }else {
            if ([model.DOOR_STATUS isEqualToString:@"1"]||[model.DOOR_STATUS isEqualToString:@"2"]) {
                imageView.image = [UIImage imageNamed:@"map_door_normal"];
            }else{
                imageView.image = [UIImage imageNamed:@"map_door_error"];
            }
        }
    }];
}

-(void)setCameraModelArr:(NSMutableArray *)cameraModelArr
{
    _cameraModelArr = cameraModelArr;
    [cameraModelArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        InDoorMonitorMapModel *model = (InDoorMonitorMapModel *)obj;
        if ([model.CAMERA_STATUS isEqualToString:@"1"]||[model.CAMERA_STATUS isEqualToString:@"2"]) {
            if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
                imageView.image = [UIImage imageNamed:@"map_gunshot_icon_normal"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                imageView.image = [UIImage imageNamed:@"map_ball_icon_normal"];
            }else{
                imageView.image = [UIImage imageNamed:@"map_halfball_icon_normal"];
            }
        }else{
            if ([model.DEVICE_TYPE isEqualToString:@"1-1"]) {
                imageView.image = [UIImage imageNamed:@"map_gunshot_icon_error"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"1-2"])
            {
                imageView.image = [UIImage imageNamed:@"map_ball_icon_error"];
            }else{
                imageView.image = [UIImage imageNamed:@"map_halfball_icon_error"];
            }
        }
    }];
}

-(void)setBgMusicArr:(NSMutableArray *)bgMusicArr
{
    _bgMusicArr = bgMusicArr;
    [bgMusicArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        InDoorBgMusicMapModel *model = (InDoorBgMusicMapModel *)obj;
        if ([model.MUSIC_STATUS isEqualToString:@"5"]) {
            if([model.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                imageView.image = [UIImage imageNamed:@"map_music_icon_error_3"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                imageView.image = [UIImage imageNamed:@"map_music_icon_error_3-3"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                imageView.image = [UIImage imageNamed:@"map_music_icon_error_3-5"];
            }

        }else{
            if([model.DEVICE_TYPE isEqualToString:@"3"]){
                // 音柱
                imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"3-3"]) {
                // 蘑菇头
                imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-3"];
            }else if ([model.DEVICE_TYPE isEqualToString:@"3-5"]) {
                // 蘑菇头
                imageView.image = [UIImage imageNamed:@"map_music_icon_normal_3-5"];
            }

        }
    }];
}

-(void)setParkLightArr:(NSMutableArray *)parkLightArr
{
    _parkLightArr = parkLightArr;
    [parkLightArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        ParkLightModel *model = (ParkLightModel *)obj;
        if ([model.EQUIP_STATUS isEqualToString:@"1"]) {
            imageView.image = [UIImage imageNamed:@"park_light_normal"];
        }else{
            imageView.image = [UIImage imageNamed:@"park_light_error"];
        }

    }];
}

- (void)setLEDMapArr:(NSMutableArray *)LEDMapArr {
    _LEDMapArr = LEDMapArr;
    
    [LEDMapArr enumerateObjectsUsingBlock:^(LedListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        // 添加动画
        [self addViewBaseAnim:imageView];
        
//        UIImageView *bottomImgView = [_mapView viewWithTag:200+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
//        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 120, 160);
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 130, 130);
//        bottomImgView.frame = CGRectMake(bottomImgView.left, bottomImgView.top + 96, 130, 130);
//        bottomImgView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        if ([model.mainstatus isEqualToString:@"1"]) {
//            imageView.image = [UIImage imageNamed:@"LED_map_icon"];
            imageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        }else{
            imageView.image = [UIImage imageNamed:@"street_lamp_light_01"];
        }
        
    }];
}

#pragma mark 添加图片变化 基础动画
- (void)addViewBaseAnim:(UIView *)view {
    CABasicAnimation *transformAnima = [CABasicAnimation animationWithKeyPath:@"contents"];
    transformAnima.fromValue = (id)[UIImage imageNamed:@"street_lamp_light_01"].CGImage;
    transformAnima.toValue = (id)[UIImage imageNamed:@"street_lamp_light_02"].CGImage;
    transformAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnima.autoreverses = YES;
    transformAnima.repeatCount = HUGE_VALF;
    transformAnima.beginTime = CACurrentMediaTime();
    transformAnima.duration = 0.5;
    [view.layer addAnimation:transformAnima forKey:@"BaseNormalAnim"];
}

-(void)setAirConArr:(NSMutableArray *)airConArr
{
    _airConArr = airConArr;
    
    [airConArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        AirConditionModel *model = (AirConditionModel *)obj;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([model.EQUIP_STATUS isEqualToString:@"1"]) {
                // 开关状态区分
                if(model.stateModel.value != nil && ![model.stateModel.value isKindOfClass:[NSNull class]] && [model.stateModel.value isEqualToString:@"0"]){
                    imageView.image = [UIImage imageNamed:@"mapaircondition_close"];
                }else {
                    imageView.image = [UIImage imageNamed:@"mapairconditionnormal"];
                }
            }else{
                imageView.image = [UIImage imageNamed:@"mapairconditionerror"];
            }
        });
        
    }];
}

-(void)setParkDownArr:(NSMutableArray *)parkDownArr
{
    _parkDownArr = parkDownArr;
    
    [parkDownArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [_mapView viewWithTag:100+idx];
        imageView.contentMode = UIViewContentModeScaleToFill;
        DownParkMdel *model = (DownParkMdel *)obj;
        if([model.seatFx isEqualToString:@"1"]){
            imageView.image = [UIImage imageNamed:@"red_hor"];
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 40, 100);
        }else if([model.seatFx isEqualToString:@"2"]) {
            imageView.image = [UIImage imageNamed:@"red_ver"];
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 100, 40);
        }
    }];
}
// 修改车库点位图图标
- (void)updateCarIcon:(DownParkMdel *)downParkMdel withIndex:(NSInteger)index {
    UIImageView *imageView = [_mapView viewWithTag:100+index];
//    [PointViewSelect recoverSelImgView:imageView];
    
    if([downParkMdel.seatFx isEqualToString:@"1"]){
        imageView.image = [UIImage imageNamed:@"sel_red_hor"];   // 搜索后的图标
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 40, 100);
    }else if([downParkMdel.seatFx isEqualToString:@"2"]) {
        imageView.image = [UIImage imageNamed:@"sel_red_ver"];   // 搜索后的图标
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 100, 40);
    }
}
- (void)normalCarIcon:(DownParkMdel *)downParkMdel withIndex:(NSInteger)index {
    UIImageView *imageView = [_mapView viewWithTag:100+index];
//    [PointViewSelect pointImageSelect:imageView];
    
    if([downParkMdel.seatFx isEqualToString:@"1"]){
        imageView.image = [UIImage imageNamed:@"red_hor"];
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 40, 100);
    }else if([downParkMdel.seatFx isEqualToString:@"2"]) {
        imageView.image = [UIImage imageNamed:@"red_ver"];
        imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 100, 40);
    }
}

-(void)tapAction:(id)sender
{
    if (self.selInMapDelegate) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        if(_selInMapDelegate && [_selInMapDelegate respondsToSelector:@selector(selInMapWithId:)]){
            [self.selInMapDelegate selInMapWithId:[NSString stringWithFormat:@"%ld",tap.view.tag]];            
        }
    }
}

#pragma mark - Zoom methods
-(void)handleDoubleTap:(UIGestureRecognizer*)gesture
{
    CGFloat newScale = self.zoomScale*1.5;
    CGRect zoonRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoonRect animated:YES];
}

-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width = self.frame.size.width /scale;
    zoomRect.origin.x = center.x -(zoomRect.size.width/2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height/2.0);
    return zoomRect;
}

#pragma mark - UIScrollViewDelegate

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
    return _mapView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:NO];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _mapView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
    
}

#pragma mark -UITouch
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGPoint touchPoint  = [[touches anyObject] locationInView:_mapView];
    NSValue *touchValue = [NSValue valueWithCGPoint:touchPoint];
    [self performSelector:@selector(performTouchTestArea:)
               withObject:touchValue
               afterDelay:0.1];
}

- (void)performTouchTestArea:(NSValue *)inTouchPoint
{
    CGPoint aTouchPoint = [inTouchPoint CGPointValue];
    
    if(_graphData != nil && _graphData.count > 0){
        [_graphData enumerateObjectsUsingBlock:^(NSString *graphStr, NSUInteger idx, BOOL * _Nonnull stop) {
            [YQIndoorMapTransfer initWithCoordinate:graphStr InPoint:aTouchPoint Inview:_mapView WithIdentity:[NSString stringWithFormat:@"%ld",idx] delegate:self];
        }];
    }
    /*
     [SKIndoorMapTransfer initWithCoordinate:@"173,451,173,559,299,563,300,590,316,592,321,628,687,632,689,334,581,335,580,447,536,448,535,465,333,464,330,448" InPoint:aTouchPoint Inview:_mapView WithTitle:@"GAP" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"922,445,921,629,1013,628,1051,598,1049,448" InPoint:aTouchPoint Inview:_mapView WithTitle:@"优视一品" delegate:self];
     [SKIndoorMapTransfer initWithCoordinate:@"1081,444,1078,598,1177,597,1215,532,1276,485,1275,444" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Samanth a Thavasa" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"1289,444,1290,484,1371,466,1451,485,1455,444,1369,421" InPoint:aTouchPoint Inview:_mapView WithTitle:@"SWATCH" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"1466,446,1467,485,1513,525,1562,595,1822,593,1818,573,1855,573,1854,443" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Izzue" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"1823,632,1823,751,1866,746,1867,630" InPoint:aTouchPoint Inview:_mapView WithTitle:@"西城旅游局" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"231,810,229,917,420,915,420,801" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Fred Perry" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"420,915,420,801,580,795,580,917" InPoint:aTouchPoint Inview:_mapView WithTitle:@"CAMPER" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"64,1051,61,1652,333,1648,331,1421,451,1420,451,1500,577,1500,521,1437,498,1375,489,1292,497,1219,526,1147,580,1078,578,1048" InPoint:aTouchPoint Inview:_mapView WithTitle:@"ZARA" delegate:self];
     
     
     [SKIndoorMapTransfer initWithCoordinate:@"680,792,813,786,813,975,680,973" InPoint:aTouchPoint Inview:_mapView WithTitle:@"MAX&CO." delegate:self];
     [SKIndoorMapTransfer initWithCoordinate:@"917,981,680,973,679,1076,749,1173,916,1173" InPoint:aTouchPoint Inview:_mapView WithTitle:@"LOVE MOSCHINO" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"917,981,916,1173,995,1126,1052,1126,1050,982" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Tissot" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"815,786,815,919,919,923,918,783" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Minnetonk" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"918,783,919,877,1036,776,1037,876" InPoint:aTouchPoint Inview:_mapView WithTitle:@"TENDENCE" delegate:self];
     [SKIndoorMapTransfer initWithCoordinate:@"1036,776,1179,769,1210,819,1202,1102,1185,1130,1052,1127,1037,876" InPoint:aTouchPoint Inview:_mapView WithTitle:@"SEPHORA" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"1293,808,1438,808,1437,849,1294,850" InPoint:aTouchPoint Inview:_mapView WithTitle:@"手表维修 " delegate:self];
     
     
     [SKIndoorMapTransfer initWithCoordinate:@"1554,799,1585,779,1807,780,1806,932,1559,933" InPoint:aTouchPoint Inview:_mapView WithTitle:@"SWAROVSKI" delegate:self];
     
     
     [SKIndoorMapTransfer initWithCoordinate:@"1559,933,1806,932,1805,1047,1560,1043" InPoint:aTouchPoint Inview:_mapView WithTitle:@"Juicy Couture" delegate:self];
     
     
     [SKIndoorMapTransfer initWithCoordinate:@"1560,1043,1805,1047,1804,1163,1559,1160" InPoint:aTouchPoint Inview:_mapView WithTitle:@"DKNY" delegate:self];
     [SKIndoorMapTransfer initWithCoordinate:@"1574,1199,1572,1406,1454,1412,1458,1582,1540,1590,1544,1701,1964,1705,1955,1287,1950,1197" InPoint:aTouchPoint Inview:_mapView WithTitle:@"H&M" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"1068,1308,1066,1430,932,1426" InPoint:aTouchPoint Inview:_mapView WithTitle:@"JurLique" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"764,1285,906,1284,906,1425,922,1429,924,1544,795,1544,795,1479,728,1474,726,1444" InPoint:aTouchPoint Inview:_mapView WithTitle:@"GUESS" delegate:self];
     
     [SKIndoorMapTransfer initWithCoordinate:@"229,917,580,914,579,1046,232,1047" InPoint:aTouchPoint Inview:_mapView WithTitle:@"CK" delegate:self];
     */
    
}

- (void)selPopWithIdentity:(NSString *)identity {
//    NSLog(@"%@", identity);
    if(self.selInMapDelegate){
        [self.selInMapDelegate selInMapWithId:identity];
    }
}

#pragma mark 配电画线路地图
- (void)drawLineMap:(NSArray *)lineData withColor:(UIColor *)lineColor{
    self.contentOffset = CGPointZero;
    
    // 图片高度
    CGFloat imgHeight = _mapView.image.size.height;
    
    if (m_shapeLayer != nil) {
        [m_shapeLayer removeFromSuperlayer];
    }
    
    m_shapeLayer = [CAShapeLayer layer];
    [m_shapeLayer setBounds:self.bounds];
    [m_shapeLayer setPosition:self.center];
    [m_shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    // 设置线颜色
    [m_shapeLayer setStrokeColor:lineColor.CGColor];
    // 3.0f设置线的宽度
    [m_shapeLayer setLineWidth:15.0f];
    //转折点圆角
    [m_shapeLayer setLineJoin:kCALineJoinRound];
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (int i = 0; i < lineData.count; i++) {
        DistributorLineModel *lineBeginModel = lineData[i];
        if (i == 0) {
            CGPathMoveToPoint(path,NULL ,lineBeginModel.xx.floatValue,imgHeight - lineBeginModel.yy.floatValue - 50);
        }else{
            CGPathAddLineToPoint(path,NULL ,lineBeginModel.xx.floatValue,imgHeight - lineBeginModel.yy.floatValue - 50);
        }
    }
    
    [m_shapeLayer setPath:path];
    CGPathRelease(path);
    [_mapView.layer addSublayer:m_shapeLayer];
    
}

@end
