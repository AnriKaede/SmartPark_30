//
//  AdcMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AdcMenuView.h"
#import "ShowMenuView.h"

@interface AdcMenuView()<MenuControlDelegate>
{
    ShowMenuView *_showMenuView;
    
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    BOOL _isRuning; // 是否正常开启
    NSString *_timeStr; // 定时
    UIColor *_timeColor; // 定时状态颜色
    NSString *_playMsg; // 当前播放
}
@end

@implementation AdcMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"广告屏";
    _stateStr = @"开关状态";
//    _stateColor = [UIColor colorWithHexString:@"#189517"];
    _timeStr = @"未定时";
    _playMsg = @"三条消息 查看详情";
    
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
            return 40;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)menuNumInView {
    return 2;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return _stateStr;
            break;
        case 1:
            return @"当前屏幕截图";
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
            return ImgConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (BOOL)isSwitch:(NSInteger)index {
    return _isRuning;
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 1){
        return _timeStr;
    }else if(index == 2){
        return _playMsg;
    }else {
        return @"";
    }
}
- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 1) {
        return _timeColor;
    }else if (index == 2){
        return [UIColor colorWithHexString:@"#FF3333"];
    }else {
        return [UIColor blackColor];
    }
}

- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"led_Screenshot";
    }
    return @"";
}
- (CGSize)imageSize:(NSInteger)index {
    return CGSizeMake(30, 30);
}

// LED开关协议
- (void)switchState:(NSInteger)index withSwitch:(BOOL)isOn {
    if([_stateStr isEqualToString:@"设备故障"]){
        return;
    }
    
    _isRuning = isOn;
    if(isOn){
        _stateStr = @"正常开启中";
        _stateColor = [UIColor colorWithHexString:@"#189517"];
    }else {
        _stateStr = @"关闭";
        _stateColor = [UIColor blackColor];
    }
    
    [self operateLED:isOn];
    
    [_showMenuView reloadMenuData];
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 1){
        if(_isRuning){
            // 截屏
            if(_currentScreenDelegate != nil && [_currentScreenDelegate respondsToSelector:@selector(currentScreen:)]){
                [_currentScreenDelegate currentScreen:_subDeviceModel];
            }
        }else {
        }
    }
}

#pragma mark 操作路灯
- (void)operateLED:(BOOL)onOff {
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/controlLed",Main_Url];
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/openAndStopScreen",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
//    [param setObject:_subDeviceModel.TAGID forKey:@"uid"];
    [param setObject:_subDeviceModel.TAGID forKey:@"tagId"];
    if(onOff){
        // 开
//        [param setObject:@"ON" forKey:@"operateType"];
        [param setObject:[NSNumber numberWithBool:YES] forKey:@"arg1"];
    }else {
        // 关
//        [param setObject:@"OFF" forKey:@"operateType"];
        [param setObject:[NSNumber numberWithBool:NO] forKey:@"arg1"];
    }
    
    NSString *jsonParam = [Utils convertToJsonData:param];
    NSDictionary *params = @{@"param":jsonParam};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            // 操作成功
            if(onOff){
                _isRuning = YES;
            }else {
                _isRuning = NO;
            }
            
            // 记录日志
            NSString *operate;
            if(onOff){
                operate = [NSString stringWithFormat:@"\"%@\"开LED广告屏", _parentDevName];
            }else {
                operate = [NSString stringWithFormat:@"\"%@\"关LED广告屏", _parentDevName];
            }
            [self logRecordOperate:operate withTagid:_subDeviceModel.TAGID];
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [[self viewController] showHint:responseObject[@"message"]];
            }
        }
        
        [_showMenuView reloadMenuData];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
- (void)logRecordOperate:(NSString *)operate withTagid:(NSString *)tagId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"roadLamp/controlLed" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:tagId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"智能路灯" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

#pragma mark 赋值model
- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    [self _loadData];
}

- (void)_loadData {
//    NSString *urkStr = [NSString stringWithFormat:@"%@/roadLamp/led",Main_Url];
    NSString *urkStr = [NSString stringWithFormat:@"%@/roadLamp/screenOpenOrStop",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
//    [param setObject:_subDeviceModel.TAGID forKey:@"uid"];
    [param setObject:_subDeviceModel.TAGID forKey:@"tagId"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [[NetworkClient sharedInstance] POST:urkStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSDictionary *lightDic = data[@"responseData"];
            if(lightDic == nil || ![lightDic isKindOfClass:[NSDictionary class]]){
                return ;
            }
            
            // 开关状态
            NSNumber *screenState = lightDic[@"result"];
            if(screenState != nil && ![screenState isKindOfClass:[NSNull class]]){
                if(screenState.boolValue == 1){
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
            
            // 当前播放
            NSString *program = lightDic[@"program"];
            if(program != nil && ![program isKindOfClass:[NSNull class]]){
                _playMsg = [NSString stringWithFormat:@"%@ 查看详情", program];
            }
            
            [_showMenuView reloadMenuData];
            
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
