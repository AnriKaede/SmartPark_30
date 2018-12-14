//
//  MusicMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MusicMenuView.h"
#import "ShowMenuView.h"

#import "ChooseMusicViewController.h"

@interface MusicMenuView()<MenuControlDelegate>
{
    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_stateStr;    // 设备状态
    UIColor *_stateColor;   // 设备状态颜色
    NSString *_currentMusic; // 当前音乐
    CGFloat _volume; // 音量
    
    BOOL _isShowMenu;
    
    SoundModel *_selectSoundModel;
    InDoorBgMusicMapModel *_selMusicmodel;
}
@end

@implementation MusicMenuView

- (instancetype)init {
    self = [super init];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    _menuTitle = @"音乐";
    _stateStr= @"开启中";
    _stateColor = [UIColor colorWithHexString:@"#189517"];
    _volume = 0.1;
    /** 当前播放任务
     7:30 -12:30   灯杆广播上午定时任务
     14:00  18:30   灯杆广播下午定时任务
     其他时间  空白
     */
    if([self judgeTimeByStartAndEnd:@"7:30" withExpireTime:@"12:30"]){
        _currentMusic = @"灯杆广播上午定时任务";
    }else if([self judgeTimeByStartAndEnd:@"14:00" withExpireTime:@"18:30"]){
        _currentMusic = @"灯杆广播下午定时任务";
    }else {
        _currentMusic = @"";
    }
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
}

- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/getRoadLampMsg", Main_Url];
    NSMutableDictionary *addParam = @{}.mutableCopy;
    [addParam setObject:_subDeviceModel.TAGID forKey:@"tagId"];
    [addParam setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName] forKey:@"user"];
    
    NSDictionary *params = @{@"param":[Utils convertToJsonData:addParam]};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData != nil  && ![code isKindOfClass:[NSNull class]]){
                NSString *bcoutv = responseData[@"bcoutv"];
                NSString *status = responseData[@"status"];
                NSString *taskName = responseData[@"taskName"];
                if(status.integerValue== 1){
                    // 正常
                    _stateStr = @"播放中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else if(status.integerValue== 0){
                    // 停止
                    _stateStr = @"空闲";
                    _stateColor = [UIColor blackColor];
                }else {
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
                
                if(taskName != nil && ![taskName isKindOfClass:[NSNull class]]){
                    _currentMusic = [NSString stringWithFormat:@"%@", taskName];
                }else {
                    _currentMusic = [NSString stringWithFormat:@""];
                }
                if(bcoutv != nil && ![bcoutv isKindOfClass:[NSNull class]]){
                    _volume = bcoutv.floatValue/15;
                }
                
                [_showMenuView reloadMenuData];
            }
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark 菜单协议
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 0){
        return 60;
    }else if(index == 1){
        return 40;
    }else{
        return 50;
    }
}

- (NSInteger)menuNumInView {
    return 3;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"设备状态";
            break;
        case 1:
            return @"当前音乐";
            break;
        case 2:
            return @"音量调节";
            break;
            
        default:
            return @"";
            break;
    }
}

- (UIColor *)menuTitleColor:(NSInteger)index {
    return [UIColor blackColor];
}
- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    switch (index) {
        case 0:
            return DefaultConMenu;
            break;
        case 1:
            return TextAndImgConMenu;
            break;
        case 2:
            return SliderConMenu;
            break;
            
        default:
            return DefaultConMenu;
            break;
    }
}

- (NSString *)menuMessage:(NSInteger)index {
    if(index == 0){
        return _stateStr;
    }else if(index == 1){
        return _currentMusic;
    }else {
        return @"";
    }
}

- (UIColor *)menuMessageColor:(NSInteger)index {
    if(index == 0){
        return _stateColor;
    }else {
        return [UIColor blackColor];
    }
}

// 为SliderConMenu时实现，默认开关状态
- (CGFloat)sliderDefValue:(NSInteger)index {
    return _volume;
}

- (NSArray *)sliderImgs:(NSInteger)index {
    return @[@"_volume_redecing", @"_volume_addition"];
}

#pragma mark 滑动slider时调用
- (void)sliderChangeValue:(CGFloat)value {
    _volume = value;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/getZoneTerminalData",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_subDeviceModel.TAGID forKey:@"id"];
    [param setObject:[NSNumber numberWithInt:value*15] forKey:@"bcoutv"];
    [param setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName] forKey:@"user"];
    
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            // 成功 记录日志
            [self logRecordOperate:[NSString stringWithFormat:@"%@调节音量到%.0f",[NSString stringWithFormat:@"%@", _subDeviceModel.DEVICE_NAME],value*15] withUid:[NSString stringWithFormat:@"%@", _subDeviceModel.SUB_DEVICE_ID]];
        }
    } failure:^(NSError *error) {
        
    }];
}

// 右侧有图片时实现
- (NSString *)imageName:(NSInteger)index {
    if(index == 1){
        return @"music_refresh_icon";
    }
    
    return @"";
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 1){
        [self chooseMusicList];
    }
}

// 是背景音乐播放时实现
- (BOOL)isPlayMusicMenu {
    return YES;
}
#pragma mark 菜单协议/tableview cell菜单协议
- (void)sliderVolumValue:(CGFloat)volum {
    _volume = volum;
}
- (void)showNoSuport {
    if(_musicOperateDelegate && [_musicOperateDelegate respondsToSelector:@selector(noSuportMsg)]){
        [_musicOperateDelegate noSuportMsg];
    }
}
- (void)chooseMusicList {
    [self hidMenu];
    [self showNoSuport];
    // 更换背景音乐
    /*
    ChooseMusicViewController *chooseMusicVC = [[ChooseMusicViewController alloc] init];
    chooseMusicVC.changeMusicDelegate = self;
    chooseMusicVC.soundModel = _selectSoundModel;
    chooseMusicVC.musicMapModel = _selMusicmodel;
    chooseMusicVC.volume = [NSString stringWithFormat:@"%f", _volume*56];
    [self.navigationController pushViewController:chooseMusicVC animated:YES];
     */
}
- (void)playMusic {
    [self hidMenu];
    [self showNoSuport];
    /*
    if(_selectSoundModel == nil){
        _showMenuView.hidden = YES;
        // 当前无播放，跳转选取歌曲播放
        [self chooseMusicList];
    }else {
        // 恢复播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/6/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr];
    }
     */
}
- (void)pauseMusic {
    [self hidMenu];
    [self showNoSuport];
    /*
    if(_selectSoundModel != nil){
        // 暂停播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/5/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
     */
}
- (void)stopMusic {
    [self hidMenu];
    [self showNoSuport];
    /*
    if(_selectSoundModel != nil){
        // 停止播放
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/1/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
     */
}
- (void)upMusic {
    [self hidMenu];
    [self showNoSuport];
    /*
    if(_selectSoundModel != nil){
        // 上一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/4/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
     */
}
- (void)downMusic {
    [self hidMenu];
    [self showNoSuport];
    /*
    if(_selectSoundModel != nil){
        // 下一曲
        NSString *urlStr = [NSString stringWithFormat:@"%@/music/playipcastfilectrl/%@/3/0", Main_Url, _selectSoundModel.sid];
        [self reloadSendRequest:urlStr];
    }else {
        [self showHint:@"当前无播放音乐"];
    }
     */
}

#pragma mark 显示隐藏
- (void)showMenu {
    _showMenuView.hidden = NO;
    [_showMenuView reloadMenuData];
}
- (void)hidMenu {
    _showMenuView.hidden = YES;
}

// 当前时间是否在时间段内 (忽略年月日)
- (BOOL)judgeTimeByStartAndEnd:(NSString *)startTime withExpireTime:(NSString *)expireTime {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
    [dateFormat setDateFormat:@"HH:mm"];
    NSString * todayStr=[dateFormat stringFromDate:today];//将日期转换成字符串
    today=[ dateFormat dateFromString:todayStr];//转换成NSDate类型。日期置为方法默认日期
    //startTime格式为 02:22   expireTime格式为 12:44
    NSDate *start = [dateFormat dateFromString:startTime];
    NSDate *expire = [dateFormat dateFromString:expireTime];
    
    if ([today compare:start] == NSOrderedDescending && [today compare:expire] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

#pragma mark 单个音箱设置音量
- (void)logRecordOperate:(NSString *)operate withUid:(NSString *)groupId {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:operate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:operate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:@"roadLamp/getZoneTerminalData" forKey:@"operateUrl"];//操作url
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
    //    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
    [logDic setObject:groupId forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"背景音乐" forKey:@"operateDeviceName"];//操作设备名  模块
    //    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}
@end
