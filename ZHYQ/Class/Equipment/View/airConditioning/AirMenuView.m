//
//  AirMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/12.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirMenuView.h"
#import "YQSwitch.h"

#import "MeetRoomStateModel.h"
#import "AirConditionModel.h"

@interface AirMenuView()<switchTapDelegate>

@end

@implementation AirMenuView
{
    UIView *_menuBgView;
    UIView *_openBgView;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    // 创建底部半透明背景
    UIView *alpBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    alpBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self insertSubview:alpBgView atIndex:0];
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
    [alpBgView addGestureRecognizer:hidTap];
    
    _menuBgView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 370, KScreenWidth, 370)];
    _menuBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_menuBgView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(KScreenWidth - 43, 10, 33, 33);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"show_menu_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [_menuBgView addSubview:closeButton];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    lineView.alpha = 0.7;
    [_menuBgView addSubview:lineView];
    
    // 空调滑动视图
    UIScrollView *listScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lineView.bottom, KScreenWidth, 54)];
    listScrollView.tag = 1001;
    listScrollView.showsVerticalScrollIndicator = NO;
    listScrollView.showsHorizontalScrollIndicator = NO;
    [_menuBgView addSubview:listScrollView];
    
    UIView *botLineView = [[UIView alloc] initWithFrame:CGRectMake(0, listScrollView.bottom, KScreenWidth, 1)];
    botLineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [_menuBgView addSubview:botLineView];
    
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, botLineView.bottom + 30, 100, 19)];
    stateLabel.tag = 2000;
    stateLabel.text = @"开启中";
    stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
    stateLabel.font = [UIFont systemFontOfSize:17];
    stateLabel.textAlignment = NSTextAlignmentLeft;
    [_menuBgView addSubview:stateLabel];
    
    YQSwitch *yqSwtch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 80, botLineView.bottom + 20, 70, 40)];
    yqSwtch.tag = 2001;
    yqSwtch.onText = @"ON";
    yqSwtch.offText = @"OFF";
    yqSwtch.on = YES;
    yqSwtch.backgroundColor = [UIColor clearColor];
    yqSwtch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    yqSwtch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    yqSwtch.switchDelegate = self;
    [_menuBgView addSubview:yqSwtch];
    
    _openBgView = [[UIView alloc] initWithFrame:CGRectMake(0, yqSwtch.bottom + 24, KScreenWidth, 370 - yqSwtch.bottom)];
    [_menuBgView addSubview:_openBgView];
    
    [self createSubOpenView];
    [self createSubCloseView];
    
}

- (void)createSubOpenView {
    UIImageView *modelImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 0, 30, 30)];
    modelImgView.tag = 3001;
    modelImgView.image = [UIImage imageNamed:@"air_cold_icon"];
    [_openBgView addSubview:modelImgView];
    
    UILabel *modelLabel = [[UILabel alloc] init];
    modelLabel.frame = CGRectMake(15,modelImgView.bottom + 15,40,19);
    modelLabel.text = @"-";
    modelLabel.tag = 3002;
    modelLabel.textAlignment = NSTextAlignmentCenter;
    modelLabel.font = [UIFont systemFontOfSize:17];
    modelLabel.textColor = [UIColor blackColor];
    [_openBgView addSubview:modelLabel];
    
    // 减温度按钮
    UIButton *reduceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reduceButton.tag = 3006;
    reduceButton.frame = CGRectMake(modelImgView.right + 20, 19, 30, 30);
    [reduceButton setBackgroundImage:[UIImage imageNamed:@"air_speed_reduce"] forState:UIControlStateNormal];
    [reduceButton addTarget:self action:@selector(reduceAction) forControlEvents:UIControlEventTouchUpInside];
    [_openBgView addSubview:reduceButton];
    
    UILabel *tmpLabel = [[UILabel alloc] init];
    tmpLabel.frame = CGRectMake(reduceButton.right,10,120,50);
    tmpLabel.tag = 3003;
    tmpLabel.text = @"-℃";
    tmpLabel.textAlignment = NSTextAlignmentCenter;
    tmpLabel.font = [UIFont systemFontOfSize:50];
    tmpLabel.textColor = [UIColor blackColor];
    [_openBgView addSubview:tmpLabel];
    
    // 加温度按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.tag = 3007;
    addButton.frame = CGRectMake(tmpLabel.right, reduceButton.top, 30, 30);
    [addButton setBackgroundImage:[UIImage imageNamed:@"air_speed_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [_openBgView addSubview:addButton];
    
    // 风速
    UILabel *windLabel = [[UILabel alloc] init];
    windLabel.frame = CGRectMake(KScreenWidth - 58 ,1 , 40,19);
    windLabel.text = @"风速";
    windLabel.textAlignment = NSTextAlignmentCenter;
    windLabel.font = [UIFont systemFontOfSize:17];
    windLabel.textColor = [UIColor blackColor];
    [_openBgView addSubview:windLabel];
    
    UIImageView *windImgView = [[UIImageView alloc] initWithFrame:CGRectMake(windLabel.left - 28, 0, 20, 20)];
    windImgView.tag = 3001;
    windImgView.image = [UIImage imageNamed:@"air_wind_speed_icon"];
    [_openBgView addSubview:windImgView];
    
    UILabel *speedLabel = [[UILabel alloc] init];
    speedLabel.frame = CGRectMake(KScreenWidth - 58 ,windLabel.bottom + 24 , 40,19);
    speedLabel.tag = 3004;
    speedLabel.text = @"-";
    speedLabel.textAlignment = NSTextAlignmentCenter;
    speedLabel.font = [UIFont systemFontOfSize:17];
    speedLabel.textColor = [UIColor blackColor];
    [_openBgView addSubview:speedLabel];
    
    UIImageView *speedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(speedLabel.left - 31, windImgView.bottom + 23, 25, 15)];
    speedImgView.tag = 3005;
    speedImgView.image = [UIImage imageNamed:@"wind_max_icon"];
    [_openBgView addSubview:speedImgView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, modelLabel.bottom + 30, KScreenWidth, 1)];
    lineView.tag = 3010;
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [_openBgView addSubview:lineView];
    
    UIButton *modelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    modelButton.tag = 3008;
    modelButton.frame = CGRectMake(20, lineView.bottom + 20, 150, 50);
    [modelButton setImage:[UIImage imageNamed:@"air_model_change"] forState:UIControlStateNormal];
    [modelButton setTitle:@"模式 " forState:UIControlStateNormal];
    [modelButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [modelButton addTarget:self action:@selector(modelChangeAction) forControlEvents:UIControlEventTouchUpInside];
    modelButton.layer.cornerRadius = 4;
    modelButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    modelButton.layer.borderWidth = 0.8;
    modelButton.titleEdgeInsets = UIEdgeInsetsMake(0, -60, 0, 0);
    modelButton.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    [_openBgView addSubview:modelButton];
    
    UIButton *speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    speedButton.tag = 3009;
    speedButton.frame = CGRectMake(KScreenWidth - 170, lineView.bottom + 20, 150, 50);
    [speedButton setImage:[UIImage imageNamed:@"air_wind_speed_blue_icon"] forState:UIControlStateNormal];
    [speedButton setTitle:@"风速 " forState:UIControlStateNormal];
    [speedButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [speedButton addTarget:self action:@selector(speedChangeAction) forControlEvents:UIControlEventTouchUpInside];
    speedButton.layer.cornerRadius = 4;
    speedButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    speedButton.layer.borderWidth = 0.8;
    speedButton.titleEdgeInsets = UIEdgeInsetsMake(0, -60, 0, 0);
    speedButton.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    [_openBgView addSubview:speedButton];
    
}
#pragma mark 模式切换
- (void)modelChangeAction {
    if(_airMenuDelegate && [_airMenuDelegate respondsToSelector:@selector(modelCut:withDeviceId:withModel:)]){
        MeetRoomStateModel *modelModel = _airConditionModel.modelModel;
        [_airMenuDelegate modelCut:modelModel.writeId withDeviceId:_deviceId withModel:_airConditionModel];
    }
}
#pragma mark 风速切换
- (void)speedChangeAction {
    if(_airMenuDelegate && [_airMenuDelegate respondsToSelector:@selector(speedCut:withDeviceId:withModel:)]){
        MeetRoomStateModel *windModel = _airConditionModel.windModel;
        [_airMenuDelegate speedCut:windModel.writeId withDeviceId:_deviceId withModel:_airConditionModel];
    }
}

#pragma mark 温度减
- (void)reduceAction {
    UILabel *tmpLabel = [_openBgView viewWithTag:3003];
    NSString *tepmStr = tmpLabel.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue - 1;
        [self tepmCut:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}
#pragma mark 温度加
- (void)addAction {
    UILabel *tmpLabel = [_openBgView viewWithTag:3003];
    NSString *tepmStr = tmpLabel.text;
    tepmStr = [tepmStr stringByReplacingOccurrencesOfString:@"℃" withString:@""];
    if(tepmStr != nil && tepmStr.length > 0){
        NSInteger tempValue = tepmStr.integerValue + 1;
        [self tepmCut:[NSString stringWithFormat:@"%ld", tempValue]];
    }
}
- (void)tepmCut:(NSString *)tepmStr {
    if(_airMenuDelegate && [_airMenuDelegate respondsToSelector:@selector(tempCut:withWriteId:withDeviceId:withModel:)]){
        MeetRoomStateModel *tempModel = _airConditionModel.tempModel;
        [_airMenuDelegate tempCut:tepmStr withWriteId:tempModel.writeId withDeviceId:_deviceId withModel:_airConditionModel];
    }
}

- (void)createSubCloseView {
    UILabel *closeLabel = [[UILabel alloc] init];
    closeLabel.hidden = YES;
    closeLabel.frame = CGRectMake(10 ,_openBgView.top , KScreenWidth - 20, 20);
    closeLabel.tag = 4001;
    closeLabel.text = @"空调设备关闭中，暂无数据。";
    closeLabel.textAlignment = NSTextAlignmentLeft;
    closeLabel.font = [UIFont systemFontOfSize:17];
    closeLabel.textColor = [UIColor colorWithHexString:@"#585858"];
    [_menuBgView addSubview:closeLabel];
}

- (void)closeAction {
    self.hidden = YES;
}
#pragma mark 开关
-(void)switchTap:(BOOL)on {
    YQSwitch *yqSwtch = [_menuBgView viewWithTag:2001];
    
    [self switchState:yqSwtch.on];
    
    if(_airMenuDelegate && [_airMenuDelegate respondsToSelector:@selector(siwtchAir:withDeviceId:withOn:withModel:)]){
        MeetRoomStateModel *stateModel = _airConditionModel.stateModel;
        [_airMenuDelegate siwtchAir:stateModel.writeId withDeviceId:_deviceId withOn:yqSwtch.on withModel:_airConditionModel];
    }
}
- (void)switchState:(BOOL)on {
    UILabel *closeLabel = [_menuBgView viewWithTag:4001];
    UILabel *stateLabel = [_menuBgView viewWithTag:2000];
    
    if(on){
        closeLabel.hidden = YES;
        _openBgView.hidden = NO;
        stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        stateLabel.text = @"开启中";
        [UIView animateWithDuration:0.3 animations:^{
            _menuBgView.frame = CGRectMake(0, KScreenHeight - 370, KScreenWidth, 370);
        }];
    }else {
        closeLabel.hidden = NO;
        _openBgView.hidden = YES;
        stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        stateLabel.text = @"关闭中";
        [UIView animateWithDuration:0.3 animations:^{
            _menuBgView.frame = CGRectMake(0, KScreenHeight - 280, KScreenWidth, 280);
        }];
    }
}

- (void)reloadMenu {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    [self _initView];
    
    CGRect bgFrame = _menuBgView.frame;
    _menuBgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
    [UIView animateWithDuration:0.15 animations:^{
        _menuBgView.frame = bgFrame;
    }];
    
    self.airConditionModel = _airConditionModel;
}

#pragma mark 设置数据
- (void)setDevices:(NSArray *)devices {
    _devices = devices;
    
    UIScrollView *listScrollView = [_menuBgView viewWithTag:1001];
    [listScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block CGFloat contentWidth = 0;
    __block CGFloat contentOffX = 0;
    [devices enumerateObjectsUsingBlock:^(AirConditionModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat itemWidth = [self widthForString:model.DEVICE_NAME fontSize:17 andHeight:54] + 20;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 5000 + idx;
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        button.frame = CGRectMake(contentWidth, 0, itemWidth, 54);
        [button setTitle:model.DEVICE_NAME forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selGroupIndex:) forControlEvents:UIControlEventTouchUpInside];
        [listScrollView addSubview:button];
        
        if(idx != devices.count - 1){
            UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(button.right, 8, 1, 36)];
            lineImgView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
            [listScrollView addSubview:lineImgView];
        }
        
        if([model.DEVICE_ID isEqualToString:_deviceId]){
            button.selected = YES;
            contentOffX = contentWidth;
        }
        
        contentWidth += itemWidth;
    }];
    
    listScrollView.contentSize = CGSizeMake(contentWidth, 0);
    if(contentWidth > KScreenWidth){
        [listScrollView setContentOffset:CGPointMake(contentOffX, 0) animated:YES];
    }
}
/*
 {
 "AIRSTATUS": {
 "actionType": "1",
 "id": 151060505,
 "name": "空调机组.F3.305-7-1开关状态",
 "type": 1,
 "value": "0",
 "writeId": "167837721"
 },
 "FAILURE": {
 "actionType": "0",
 "id": 151060607,
 "name": "空调机组.F3.305-7-1故障",
 "type": 1,
 "value": "0"
 },
 "TEMPERATUR": {
 "actionType": "1",
 "id": 151060508,
 "name": "空调机组.F3.305-7-1温度",
 "type": 1,
 "value": "0",
 "writeId": "167837724"
 },
 "WINDSPEED": {
 "actionType": "1",
 "id": 151060506,
 "name": "空调机组.F3.305-7-1风速",
 "type": 1,
 "value": "0",
 "writeId": "167837722"
 },
 "WORKMODE": {
 "actionType": "1",
 "id": 151060507,
 "name": "空调机组.F3.305-7-1模式",
 "type": 1,
 "value": "0",
 "writeId": "167837723"
 }
 }
 */
- (void)setAirConditionModel:(AirConditionModel *)airConditionModel {
    _airConditionModel = airConditionModel;
    
    MeetRoomStateModel *airStateModel = airConditionModel.stateModel;
    MeetRoomStateModel *windModel = airConditionModel.windModel;
    MeetRoomStateModel *modelModel = airConditionModel.modelModel;
    MeetRoomStateModel *tempModel = airConditionModel.tempModel;
    MeetRoomStateModel *failModel = airConditionModel.failureModel;
    
    // 开关状态
    UILabel *stateLabel = [_menuBgView viewWithTag:2000];
    YQSwitch *yqSwtch = [_menuBgView viewWithTag:2001];
    if(airStateModel.value != nil && ![airStateModel.value isKindOfClass:[NSNull class]] && ![airStateModel.value isEqualToString:@"0"]){
        yqSwtch.on = YES;
        stateLabel.text = @"开启中";
        stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
        [self switchState:yqSwtch.on];
        
        // 判断是否有权限控制
        if((modelModel.actionType != nil && ![modelModel.actionType isKindOfClass:[NSNull class]] && [modelModel.actionType isEqualToString:@"1"]) ||
           (tempModel.actionType != nil && ![tempModel.actionType isKindOfClass:[NSNull class]] && [tempModel.actionType isEqualToString:@"1"]) ||
           (windModel.actionType != nil && ![windModel.actionType isKindOfClass:[NSNull class]] && [windModel.actionType isEqualToString:@"1"])){
            // 有模式、温度、风速权限
            [self controlView:YES];
        }else {
            [self controlView:NO];
        }
        
    }else {
        yqSwtch.on = NO;
        stateLabel.text = @"关闭中";
        stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
        [self switchState:yqSwtch.on];
    }
    
    // 是否可控
    if(airStateModel.actionType != nil && ![airStateModel.actionType isKindOfClass:[NSNull class]] && [airStateModel.actionType isEqualToString:@"1"]){
        yqSwtch.enabled = YES;
    }else {
        yqSwtch.enabled = NO;
    }

    // 风速
    if(windModel.value != nil && ![windModel.value isKindOfClass:[NSNull class]]){
        UILabel *speedLabel = [_openBgView viewWithTag:3004];
        UIImageView *speedImgView = [_openBgView viewWithTag:3005];
        speedImgView.frame = CGRectMake(speedImgView.left, speedImgView.top, 25, 15);
        if([windModel.value isEqualToString:@"3"]){
            speedLabel.text = @"低";
            speedImgView.image = [UIImage imageNamed:@"wind_low_icon"];
        }
        if([windModel.value isEqualToString:@"2"]){
            speedLabel.text = @"中";
            speedImgView.image = [UIImage imageNamed:@"wind_medium_icon"];
        }
        if([windModel.value isEqualToString:@"1"]){
            speedLabel.text = @"高";
            speedImgView.image = [UIImage imageNamed:@"wind_max_icon"];
        }if([windModel.value isEqualToString:@"0"]){
            speedLabel.text = @"自动";
            speedImgView.image = [UIImage imageNamed:@"wind_auto_icon"];
            speedImgView.frame = CGRectMake(speedImgView.left, speedImgView.top, 20, 20);
        }
    }
    // 是否可控
    UIButton *speedButton = [_openBgView viewWithTag:3009];
    if(windModel.actionType != nil && ![windModel.actionType isKindOfClass:[NSNull class]] && [windModel.actionType isEqualToString:@"1"]){
        speedButton.enabled = YES;
        [speedButton setImage:[UIImage imageNamed:@"air_wind_speed_blue_icon"] forState:UIControlStateNormal];
        [speedButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        speedButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    }else {
        speedButton.enabled = NO;
        [speedButton setImage:[UIImage imageNamed:@"air_wind_speed_gray_icon"] forState:UIControlStateNormal];
        [speedButton setTitleColor:[UIColor colorWithHexString:@"#A8A8A8"] forState:UIControlStateNormal];
        speedButton.layer.borderColor = [UIColor colorWithHexString:@"#A8A8A8"].CGColor;
    }
    
    // 模式
    if(modelModel.value != nil && ![modelModel.value isKindOfClass:[NSNull class]]){
        UIImageView *modelImgView = [_openBgView viewWithTag:3001];
        UILabel *modelLabel = [_openBgView viewWithTag:3002];
        if([modelModel.value isEqualToString:@"1"]){
            modelLabel.text = @"制热";
            modelImgView.image = [UIImage imageNamed:@"air_hot_icon"];
        }
        if([modelModel.value isEqualToString:@"2"]){
            modelLabel.text = @"制冷";
            modelImgView.image = [UIImage imageNamed:@"air_cold_icon"];
        }
        if([modelModel.value isEqualToString:@"4"]){
            modelLabel.text = @"除湿";
            modelImgView.image = [UIImage imageNamed:@"air_wet_icon"];
        }
        if([modelModel.value isEqualToString:@"3"]){
            modelLabel.text = @"通风";
            modelImgView.image = [UIImage imageNamed:@"air_wind_icon"];
        }
    }
    // 是否可控
    UIButton *modelButton = [_openBgView viewWithTag:3008];
    if(modelModel.actionType != nil && ![modelModel.actionType isKindOfClass:[NSNull class]] && [modelModel.actionType isEqualToString:@"1"]){
        modelButton.enabled = YES;
        [modelButton setImage:[UIImage imageNamed:@"air_model_change"] forState:UIControlStateNormal];
        [modelButton setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        modelButton.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    }else {
        modelButton.enabled = NO;
        [modelButton setImage:[UIImage imageNamed:@"air_model_change_uneble"] forState:UIControlStateNormal];
        [modelButton setTitleColor:[UIColor colorWithHexString:@"#A8A8A8"] forState:UIControlStateNormal];
        modelButton.layer.borderColor = [UIColor colorWithHexString:@"#A8A8A8"].CGColor;
    }

    // 温度
    if(tempModel.value != nil && ![tempModel.value isKindOfClass:[NSNull class]]){
        UILabel *tmpLabel = [_openBgView viewWithTag:3003];
        tmpLabel.text = [NSString stringWithFormat:@"%@℃", tempModel.value];
    }
    // 是否可控
    UIButton *reduceButton = [_openBgView viewWithTag:3006];
    UIButton *addButton = [_openBgView viewWithTag:3007];
    if(tempModel.actionType != nil && ![tempModel.actionType isKindOfClass:[NSNull class]] && [tempModel.actionType isEqualToString:@"1"]){
        reduceButton.enabled = YES;
        [reduceButton setBackgroundImage:[UIImage imageNamed:@"air_speed_reduce"] forState:UIControlStateNormal];
        addButton.enabled = YES;
        [addButton setBackgroundImage:[UIImage imageNamed:@"air_speed_add"] forState:UIControlStateNormal];
    }else {
        reduceButton.enabled = NO;
        [reduceButton setBackgroundImage:[UIImage imageNamed:@"air_speed_reduce_unable"] forState:UIControlStateNormal];
        addButton.enabled = NO;
        [addButton setBackgroundImage:[UIImage imageNamed:@"air_speed_add_unable"] forState:UIControlStateNormal];
    }
    
    // 是否故障
    if(failModel.value != nil && ![failModel.value isKindOfClass:[NSNull class]] && ![failModel.value isEqualToString:@"0"]){
        stateLabel.text = @"故障";
        stateLabel.textColor = [UIColor grayColor];
    }
}
// 根据是否有权限控制页面
- (void)controlView:(BOOL)isCon {
    UIButton *reduceBt = [_openBgView viewWithTag:3006];
    UIButton *addBt = [_openBgView viewWithTag:3007];
    UIButton *modelBt = [_openBgView viewWithTag:3008];
    UIButton *windBt = [_openBgView viewWithTag:3009];
    UIView *lineView = [_openBgView viewWithTag:3010];
    if(isCon){
        // 可控
        reduceBt.hidden = NO;
        addBt.hidden = NO;
        modelBt.hidden = NO;
        windBt.hidden = NO;
        lineView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            _menuBgView.frame = CGRectMake(0, KScreenHeight - 370, KScreenWidth, 370);
        }];
    }else {
        // 不可控
        reduceBt.hidden = YES;
        addBt.hidden = YES;
        modelBt.hidden = YES;
        windBt.hidden = YES;
        lineView.hidden = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            _menuBgView.frame = CGRectMake(0, KScreenHeight - 280, KScreenWidth, 280);
        }];
    }
}

#pragma mark 点击ScrollView按钮切换 空调
- (void)selGroupIndex:(UIButton *)button {
    UIScrollView *listScrollView = [_menuBgView viewWithTag:1001];
    [listScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[UIButton class]]){
            UIButton *subBt = (UIButton *)obj;
            if(subBt.tag == button.tag){
                subBt.selected = YES;
            }else {
                subBt.selected = NO;
            }
        }
    }];
    
    if(_devices.count > button.tag-5000){
        AirConditionModel *model = _devices[button.tag-5000];
        if(_airMenuDelegate && [_airMenuDelegate respondsToSelector:@selector(cutAirControl:)]){
            [_airMenuDelegate cutAirControl:model];
        }
    }
}

//获取字符串的宽度
-(float)widthForString:(NSString *)value fontSize:(float)fontSize andHeight:(float)height
{
    UIColor  *backgroundColor=[UIColor blackColor];
    UIFont *font=[UIFont boldSystemFontOfSize:fontSize];
    CGRect sizeToFit = [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{                                                                               NSForegroundColorAttributeName:backgroundColor,                                                                                NSFontAttributeName:font                                                                         } context:nil];
    return sizeToFit.size.width;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(!hidden){
        CGRect bgFrame = _menuBgView.frame;
        _menuBgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
        [UIView animateWithDuration:0.15 animations:^{
            _menuBgView.frame = bgFrame;
        }];
    }
}

@end
