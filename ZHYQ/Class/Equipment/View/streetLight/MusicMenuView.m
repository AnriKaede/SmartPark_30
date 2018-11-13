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
    _stateStr= @"-";
    _volume = 0;
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
}

- (void)setSubDeviceModel:(SubDeviceModel *)subDeviceModel {
    _subDeviceModel = subDeviceModel;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/music/getipcasttermsessionstatus/%@", Main_Url, subDeviceModel.SUB_DEVICE_ID];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            if(arr != nil && arr.count > 0){
                SoundModel *model = [[SoundModel alloc] initWithDataDic:arr.firstObject];
                if(model.name != nil && ![model.name isKindOfClass:[NSNull class]]){
                    _currentMusic = model.name;
                }
                if(model.status.integerValue== 1){
                    // 正常
                    _stateStr = @"正常开启中";
                    _stateColor = [UIColor colorWithHexString:@"#189517"];
                }else if(model.status.integerValue== 0){
                    // 停止
                    _stateStr = @"停止";
                    _stateColor = [UIColor grayColor];
                }else if(model.status.integerValue== 2){
                    // 暂停
                    _stateStr = @"暂停";
                    _stateColor = [UIColor blackColor];
                }else {
                    _stateStr = @"离线";
                    _stateColor = [UIColor grayColor];
                }
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
- (void)chooseMusicList {
    _isShowMenu = YES;
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

@end
