//
//  LightVMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LightVMenuView.h"
#import "ShowMenuView.h"

@interface LightVMenuView ()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    BOOL _isRuning; // 是否正常开启
    CGFloat _sliderValue; // 亮度值
    NSString *_voltageStr;   // 电压
    NSString *_frequencyStr; // 频率
    NSString *_temperatureStr; // 温度
    NSString *_timeStr; // 定时
    NSString *_timeColor; // 定时状态颜色
//    NSString *_equipInfo; // 设备信息
    NSString *_lightTime; // 亮灯时长

}
@end

@implementation LightVMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"照明";
    _stateStr = @"正常开启中";
    _voltageStr = @"-";
    _frequencyStr = @"-";
    _temperatureStr = @"-";
    _timeStr = @"未定时";
//    _equipInfo = @"信息";
    _lightTime = @"00:00:00";
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
}

- (void)showMenu {
    _showMenuView.hidden = NO;
    [_showMenuView reloadMenuData];
}
- (void)hidMenu {
    _showMenuView.hidden = YES;
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    switch (index) {
        case 0:
            return 60;
            break;
        case 1:
            return 50;
            break;
            
        default:
            return 40;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 7;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
        case 1:
            return @"亮度调节";
            break;
        case 2:
            return @"电压";
            break;
        case 3:
            return @"频率";
            break;
        case 4:
            return @"温度";
            break;
        case 5:
            return @"定时装置";
            break;
//        case 6:
//            return @"设备信息";
//            break;
        case 6:
            return @"运行时长";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return SwitchConMenu;
            break;
        case 1:
            return SliderConMenu;
            break;
        case 5:
            return TextAndImgConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (BOOL)isSwitch:(NSInteger)index {
    return _isRuning;
}

- (CGFloat)sliderDefValue:(NSInteger)index {
    return _sliderValue;
}
- (NSArray *)sliderImgs:(NSInteger)index {
    return @[@"_light_zero_icon", @"_light_full_icon"];
}

- (NSString *)imageName:(NSInteger)index {
    if(index == 5){
        return @"_dingshi_clock";
    }
    return @"";
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 2){
        return _voltageStr;
    }else if(index == 3){
        return _frequencyStr;
    }else if(index == 4){
        return _temperatureStr;
    }else if(index == 5){
        return _timeStr;
    }else if(index == 6){
        return _lightTime;
    }else {
        return @"";
    }
}

// 监控开关协议
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn {
    if([_stateStr isEqualToString:@"设备故障"]){
        return;
    }
    
    if(isOn){
        [self operateLight:YES withOperateValue:@"ON"];
    }else {
        [self operateLight:YES withOperateValue:@"OFF"];
    }
    
//    [_showMenuView reloadMenuData];
}

// 滑动条滑动协议
- (void)sliderChangeValue:(CGFloat)value {
    
    [self operateLight:NO withOperateValue:[NSString stringWithFormat:@"%f", value*100]];
}

- (void)didSelectMenu:(NSInteger)index {
    switch (index) {
        case 5:
        {
            
        }
            
    }
}

#pragma mark 操作路灯
- (void)operateLight:(BOOL)isOnOff withOperateValue:(NSString *)operateValue {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/controlLamp",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_subDeviceModel.TAGID forKey:@"uid"];
    if(_subDeviceModel.DEVICE_ADDR != nil && ![_subDeviceModel.DEVICE_ADDR isKindOfClass:[NSNull class]]){
        [param setObject:_subDeviceModel.DEVICE_ADDR forKey:@"lampCtrlAddr"];
    }
    [param setObject:@"13" forKey:@"lampCtrlType"];
    if(isOnOff){
        // 开关
        [param setObject:@"on" forKey:@"operateType"];
        [param setObject:operateValue forKey:@"operateValue"];
    }else {
        // 亮度调节
        [param setObject:@"bri" forKey:@"operateType"];
        [param setObject:operateValue forKey:@"operateValue"];
    }
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 操作成功
            if(isOnOff){
                NSString *operate;
                if([operateValue isEqualToString:@"ON"]){
                    _isRuning = YES;
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                    operate = [NSString stringWithFormat:@"\"%@\"开LED路灯", _parentDevName];
                }else if([operateValue isEqualToString:@"OFF"]){
                    _isRuning = NO;
                    _stateStr = @"关闭";
                    _stateColor = [UIColor blackColor];
                    operate = [NSString stringWithFormat:@"\"%@\"关LED路灯", _parentDevName];
                }
                // 记录日志
                [self logRecordOperate:operate withUid:_subDeviceModel.TAGID];
            }else {
                // 记录日志
                [self logRecordBriUid:_subDeviceModel.TAGID withOldValue:_sliderValue*100 withNewValue:operateValue.floatValue];
                // 亮度
                _sliderValue = operateValue.floatValue/100;
            }
            
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [[Utils getCurrentVC] showHint:responseObject[@"message"]];
            }
        }
        
        [_showMenuView reloadMenuData];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
#pragma mark 开关日志
- (void)logRecordOperate:(NSString *)operate withUid:(NSString *)uid {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"roadLamp/controlLamp" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:uid forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能路灯" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}
#pragma mark 亮度调节日志
- (void)logRecordBriUid:(NSString *)uid withOldValue:(CGFloat)oldValue withNewValue:(CGFloat)newValue {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:[NSString stringWithFormat:@"\"%@\"LED路灯调节亮度", _parentDevName] forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:[NSString stringWithFormat:@"\"%@\"LED路灯调节亮度%.0f至%.0f", _parentDevName, oldValue, newValue] forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"roadLamp/controlLamp" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    [logDic setObject:[NSString stringWithFormat:@"%.0f", newValue] forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:uid forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能路灯" forKey:@"operateDeviceName"];//操作设备名  模块
    [logDic setObject:[NSString stringWithFormat:@"%.0f", oldValue] forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 赋值model
- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    [self _loadData];
}

- (void)_loadData {
    NSString *urkStr = [NSString stringWithFormat:@"%@/roadLamp/lamp",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_subDeviceModel.TAGID forKey:@"uid"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [[NetworkClient sharedInstance] POST:urkStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *lightDic = data[@"responseData"];
            if(lightDic == nil || ![lightDic isKindOfClass:[NSDictionary class]]){
                return ;
            }
            
            // 状态(在线、离线)
            NSNumber *online = lightDic[@"online"];
            if(online != nil && ![online isKindOfClass:[NSNull class]]){
                if(online.integerValue == 1){
                    _menuTitle = [NSString stringWithFormat:@"照明(在线)"];
                }else {
                    _menuTitle = [NSString stringWithFormat:@"照明(离线)"];
                }
            }
            
            // 开关状态
            NSNumber *on = lightDic[@"on"];
            if(on != nil && ![on isKindOfClass:[NSNull class]]){
                if(on.integerValue == 1){
                    _isRuning = YES;
                }else {
                    _isRuning = NO;
                }
                
                if(_isRuning){
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else {
                    _stateStr = @"关闭";
                    _stateColor = [UIColor blackColor];
                }
            }
            
            // 亮度值
            NSNumber *bri = lightDic[@"bri"];
            if(bri != nil && ![bri isKindOfClass:[NSNull class]]){
                _sliderValue = bri.floatValue/100;
            }
            
            // 电压
            NSString *voltage = lightDic[@"voltage"];
            if(voltage != nil && ![voltage isKindOfClass:[NSNull class]]){
                _voltageStr = [NSString stringWithFormat:@"%@ V", voltage];
            }
            
            // 频率
            NSString *frequency = lightDic[@"frequency"];
            if(frequency != nil && ![frequency isKindOfClass:[NSNull class]]){
                _frequencyStr = [NSString stringWithFormat:@"%@ HZ", frequency];
            }
            
            // 温度
            NSString *temperature = lightDic[@"temperature"];
            if(temperature != nil && ![temperature isKindOfClass:[NSNull class]]){
                _temperatureStr = [NSString stringWithFormat:@"%@ ℃", temperature];
            }
            
            // 运行时长
            NSString *runtime = lightDic[@"runtime"];
            if(runtime != nil && ![runtime isKindOfClass:[NSNull class]]){
                _lightTime = [self traceTime:runtime];
            }
            
            [_showMenuView reloadMenuData];
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSString *)traceTime:(NSString *)traceTime {
    CGFloat time = traceTime.floatValue * 60;
    NSString *timeStr;
    if(time/3600 > 24) {
        timeStr = [NSString stringWithFormat:@"%.1d天%.1d小时%.1d分钟", (int)time/3600/24, (int)time/60/60%24, (int)time/60%60];
    }else if(time/3600 > 1){
        timeStr = [NSString stringWithFormat:@"%.1d小时%.1d分钟", (int)time/3600, (int)time%3600/60];
    }else {
        timeStr = [NSString stringWithFormat:@"%.1d分钟", (int)time%3600/60];
    }
    return timeStr;
}

@end
