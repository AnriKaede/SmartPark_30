//
//  LEDMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDMenuView.h"
#import "YQSwitch.h"

@interface LEDMenuView()<switchTapDelegate>
@property (nonatomic,retain) LedListModel *ledListModel;
@end

@implementation LEDMenuView
{
    __weak IBOutlet UIView *_menuBgView;
    
    __weak IBOutlet UIView *_topBgView;
    
    __weak IBOutlet UILabel *_stateLabel;
    YQSwitch *_yqSwitch;
    
    __weak IBOutlet UILabel *_currentLabel;
    
    __weak IBOutlet UILabel *_pcStateLabel;
    
    __weak IBOutlet UIButton *_defaultBt;
    __weak IBOutlet UIButton *_restartBt;
    __weak IBOutlet UIButton *_playBt;
    __weak IBOutlet UIButton *_closeBt;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self){
//        [self _initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _initView];
}

- (void)_initView {
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    
    UIView *alpBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    alpBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self insertSubview:alpBgView atIndex:0];
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidMenuAction)];
    [alpBgView addGestureRecognizer:hidTap];
    
    _yqSwitch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 71, 65, 60, 30)];
    _yqSwitch.onText = @"ON";
    _yqSwitch.offText = @"OFF";
    _yqSwitch.backgroundColor = [UIColor clearColor];
    _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _yqSwitch.switchDelegate = self;
    [_menuBgView addSubview:_yqSwitch];
    
    _pcStateLabel.layer.cornerRadius = 5;
    _pcStateLabel.layer.masksToBounds = YES;
}

- (void)hidMenuAction {
    self.hidden = YES;
}

-(void)switchTap:(BOOL)on {
    NSLog(@"%d", on);
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(ledSwitch:withModel:)]) {
        [_ledMenuDelegate ledSwitch:_yqSwitch.on withModel:_ledListModel];
    }
}

- (void)setModelAry:(NSArray *)modelAry {
    _modelAry = modelAry;
    
#warning 请求状态信息接口
    
    if(modelAry && modelAry.count > 0){
#warning 数据
//        self.ledListModel = modelAry.firstObject;
        // 标题
        CGFloat itemWidth = KScreenWidth/modelAry.count;
        [modelAry enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 3000+idx;
            button.frame = CGRectMake(itemWidth * idx, 0, itemWidth, 50);
            [button setTitle:ledListModel.deviceName forState:UIControlStateNormal];
            if(idx == 0){
                [button setTitleColor:[UIColor colorWithHexString:@"#009CF3"] forState:UIControlStateNormal];
            }else {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [button addTarget:self action:@selector(selLEDActoin:) forControlEvents:UIControlEventTouchUpInside];
            [_topBgView addSubview:button];
        }];
        [self addLine:itemWidth + 1];
    }
}
- (void)addLine:(CGFloat)orgX {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(orgX, 0, 1, 50)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [_topBgView addSubview:lineView];
}
- (void)selLEDActoin:(UIButton *)selBt {
    [selBt setTitleColor:[UIColor colorWithHexString:@"#009CF3"] forState:UIControlStateNormal];
    for (int i=0; i<_modelAry.count; i++) {
        UIButton *itemBt = [_topBgView viewWithTag:3000+i];
        if(itemBt != selBt){
            [itemBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    self.ledListModel = _modelAry[selBt.tag - 3000];
}

#pragma mark 请求单个LED设备信息
- (void)loadLEDInfo:(LedListModel *)model {
    NSString *urlStr = [NSString stringWithFormat:@"%@/ledController/getAppLedStatus",Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    if(model.type){
        [param setObject:[NSString stringWithFormat:@"%@", model.deviceId] forKey:@"id"];
    }else {
        [param setObject:[NSString stringWithFormat:@"%@", model.tagid] forKey:@"id"];
    }
    NSDictionary *paramDic =@{@"param":[Utils convertToJsonData:param]};
    [[NetworkClient sharedInstance] POST:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
//        if ([responseObject[@"code"] isEqualToString:@"1"]) {
//            NSDictionary *dic = responseObject[@"responseData"];
//        }
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)setLedListModel:(LedListModel *)ledListModel {
    _ledListModel = ledListModel;
    
    if([ledListModel.status isEqualToString:@"1"]){
        // 在线
        _yqSwitch.on = YES;
        _pcStateLabel.text = @"已开启";
        _pcStateLabel.backgroundColor = [UIColor colorWithHexString:@"#009CF3"];
        
        _playBt.enabled = NO;
        _restartBt.enabled = YES;
        _closeBt.enabled = YES;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        [_restartBt setBackgroundImage:[UIImage imageNamed:@"led_restart_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_close_icon"] forState:UIControlStateNormal];
        _defaultBt.enabled = YES;
    }else {
        // 离线
        _yqSwitch.on = NO;
        _pcStateLabel.text = @"关闭";
        _pcStateLabel.backgroundColor = [UIColor colorWithHexString:@"#A5A5A5"];
        
        _playBt.enabled = YES;
        _restartBt.enabled = NO;
        _closeBt.enabled = NO;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_play_icon"] forState:UIControlStateNormal];
        [_restartBt setBackgroundImage:[UIImage imageNamed:@"led_restart_enable_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        _defaultBt.enabled = NO;
    }
    
    if(_ledListModel.program != nil && ![_ledListModel.program isKindOfClass:[NSNull class]]){
        _currentLabel.text = [NSString stringWithFormat:@"%@", _ledListModel.program];
    }else {
        _currentLabel.text = [NSString stringWithFormat:@"%@", @""];
    }
    
    // 路灯屏
    if([ledListModel.type isEqualToString:@"1"]){
        _playBt.enabled = NO;
        _closeBt.enabled = NO;
        [_playBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        [_closeBt setBackgroundImage:[UIImage imageNamed:@"led_closeOpen_enable_icon"] forState:UIControlStateNormal];
        
        if([ledListModel.mainstatus isEqualToString:@"1"]){
            _yqSwitch.on = YES;
            _stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
            _stateLabel.text = @"屏幕开启中";
        }else {
            _yqSwitch.on = NO;
            _stateLabel.textColor = [UIColor grayColor];
            _stateLabel.text = @"屏幕已关闭";
        }
    }else {

    }
}

- (IBAction)currentScreen:(id)sender {
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(lookScreenShotWithModel:)]) {
        [_ledMenuDelegate lookScreenShotWithModel:_ledListModel];
    }
}

- (IBAction)restartAction:(id)sender {
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(ledRestart:)]) {
        [_ledMenuDelegate ledRestart:_ledListModel];
    }
}
- (IBAction)playAction:(id)sender {
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(ledPlay:)]) {
        [_ledMenuDelegate ledPlay:_ledListModel];
    }
}
- (IBAction)closeAction:(id)sender {
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(ledClose:)]) {
        [_ledMenuDelegate ledClose:_ledListModel];
    }
}

- (IBAction)defaultAction:(id)sender {
    if (_ledMenuDelegate != nil && [_ledMenuDelegate respondsToSelector:@selector(resumeDefault:)]) {
        [_ledMenuDelegate resumeDefault:_ledListModel];
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
    
    self.modelAry = _modelAry;
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
