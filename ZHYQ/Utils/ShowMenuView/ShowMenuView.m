//
//  ShowMenuView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/6.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ShowMenuView.h"
#import "YQSwitch.h"
#import "YQSlider.h"

@interface ShowMenuView()<YQSliderDelegate>

@end

@implementation ShowMenuView
{
    // 菜单背景
//    UIView *_menuBgView;
    
    // 是否初始化，判断是否执行动画
    BOOL _isInit;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    if(self){
        [self _initView];
    }
    return self;
}
- (void)_initView {
    
    // 创建底部半透明背景
    UIView *alpBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    alpBgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self addSubview:alpBgView];
    
    UITapGestureRecognizer *hidTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction)];
    [alpBgView addGestureRecognizer:hidTap];
}

- (void)setMenuDelegate:(id<MenuControlDelegate>)menuDelegate {
    _menuDelegate = menuDelegate;
    
    if(_menuDelegate == nil){
        return;
    }
    
    [self _createMenView];  // 刷新时创建
}
#pragma mark 根据协议方法创建视图
- (void) _createMenView{
    // 获取行数
    NSInteger indexNums = [_menuDelegate menuNumInView];
    
    // 菜单背景View
    _menuBgView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat bgHeight = 50;   // 总高度(默认加上titleView固定50)
    
    // titleView
    [self _createTitleVIew];
    
    for (int index=0; index<indexNums; index++) {
        CGFloat indexHeight = [_menuDelegate menuHeightInView:index];
        bgHeight += indexHeight;
        
        // 菜单某行View
        UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, bgHeight - indexHeight, KScreenWidth, indexHeight)];
        menuView.tag = 1000 + index;
        [_menuBgView addSubview:menuView];
        
        NSString *titleStr = [_menuDelegate menuTitle:index];
        UIFont *titleFont = [UIFont systemFontOfSize:17];
        CGSize titleSize = [titleStr sizeWithAttributes:@{NSFontAttributeName:titleFont}];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, menuView.height/2 - 16/2, titleSize.width, 16)];
        titleLabel.text = titleStr;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = titleFont;
        if([_menuDelegate respondsToSelector:@selector(menuTitleColor:)]){        
            titleLabel.textColor = [_menuDelegate menuTitleColor:index];
        }
        [menuView addSubview:titleLabel];
        
        if([_menuDelegate respondsToSelector:@selector(menuTitleImgName:)]){
            UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.right + 10, titleLabel.top-2, 20, 20)];
            titleImgView.image = [UIImage imageNamed:[_menuDelegate menuTitleImgName:index]];
            [menuView addSubview:titleImgView];
        }
        
        switch ([_menuDelegate menuViewStyle:index]) {
                
            case DefaultConMenu:
            {
                [self _createDefMenu:menuView];
                break;
            }
                
            case SwitchConMenu:
            {
                [self _createSwitchMenu:menuView];
                break;
            }
                
            case SliderConMenu:
            {
                [self _createSlider:menuView];
                break;
            }
                
            case ImgConMenu:
            {
                [self _createImage:menuView];
                break;
            }
                
            case TextAndImgConMenu:
            {
                [self _createTextImg:menuView];
                break;
            }
                
            default:
                break;
        }
        
    }
    
    // 音乐播放菜单
    CGFloat menuBgHeight = bgHeight + 20;
    if([_menuDelegate respondsToSelector:@selector(isPlayMusicMenu)] && [_menuDelegate isPlayMusicMenu]){
        menuBgHeight += 70;
        [self _createMusicMenu:menuBgHeight - 90];
    }
    _menuBgView.frame =CGRectMake(0, KScreenHeight - menuBgHeight, KScreenWidth, menuBgHeight);
    _menuBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_menuBgView];
}

- (void)_createTitleVIew {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    titleView.backgroundColor = [UIColor whiteColor];
    [_menuBgView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake(50,15,KScreenWidth - 100,20);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = [_menuDelegate menuTitleViewText];
    titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:20];
    titleLabel.textColor = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:1];
    [titleView addSubview:titleLabel];
    
    UIButton *closeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBt.frame =CGRectMake(KScreenWidth - 40, 10, 30, 30);
    [closeBt setBackgroundImage:[UIImage imageNamed:@"show_menu_close"] forState:UIControlStateNormal];
    [closeBt addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeBt];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleView.height - 0.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [titleView addSubview:lineView];
    
}
- (void)closeAction {
    if (self.menuDelegate != nil && [self.menuDelegate respondsToSelector:@selector(closeMenu)]) {
        [self.menuDelegate closeMenu];
    }
    self.hidden = YES;
}

- (void)_createMusicMenu:(CGFloat)top {
    UIView *musicBgView = [[UIView alloc] initWithFrame:CGRectMake(0, top, KScreenWidth, 70)];
    [_menuBgView addSubview:musicBgView];
    
    UIButton *playBt = [UIButton buttonWithType:UIButtonTypeCustom];
    playBt.frame = CGRectMake((KScreenWidth - 60)/2, 0, 60, 60);
    [playBt setBackgroundImage:[UIImage imageNamed:@"music_play_nor"] forState:UIControlStateNormal];
    [playBt setBackgroundImage:[UIImage imageNamed:@"music_play_sel"] forState:UIControlStateHighlighted];
    [playBt addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [musicBgView addSubview:playBt];
    
    UIButton *pauseBt = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseBt.frame = CGRectMake(playBt.left - 50, 5, 50, 50);
    [pauseBt setBackgroundImage:[UIImage imageNamed:@"music_pause_nor"] forState:UIControlStateNormal];
    [pauseBt setBackgroundImage:[UIImage imageNamed:@"music_pause_sel"] forState:UIControlStateHighlighted];
    [pauseBt addTarget:self action:@selector(pauseAction) forControlEvents:UIControlEventTouchUpInside];
    [musicBgView addSubview:pauseBt];
    
    UIButton *stopBt = [UIButton buttonWithType:UIButtonTypeCustom];
    stopBt.frame = CGRectMake(playBt.right, 5, 50, 50);
    [stopBt setBackgroundImage:[UIImage imageNamed:@"music_stop_nor"] forState:UIControlStateNormal];
    [stopBt setBackgroundImage:[UIImage imageNamed:@"music_stop_sel"] forState:UIControlStateHighlighted];
    [stopBt addTarget:self action:@selector(stopAction) forControlEvents:UIControlEventTouchUpInside];
    [musicBgView addSubview:stopBt];
    
    UIButton *upBt = [UIButton buttonWithType:UIButtonTypeCustom];
    upBt.frame = CGRectMake(pauseBt.left - 50, 5, 50, 50);
    [upBt setBackgroundImage:[UIImage imageNamed:@"music_up_nor"] forState:UIControlStateNormal];
    [upBt setBackgroundImage:[UIImage imageNamed:@"music_up_sel"] forState:UIControlStateHighlighted];
    [upBt addTarget:self action:@selector(upAction) forControlEvents:UIControlEventTouchUpInside];
    [musicBgView addSubview:upBt];
    
    UIButton *downBt = [UIButton buttonWithType:UIButtonTypeCustom];
    downBt.frame = CGRectMake(stopBt.right, 5, 50, 50);
    [downBt setBackgroundImage:[UIImage imageNamed:@"music_down_nor"] forState:UIControlStateNormal];
    [downBt setBackgroundImage:[UIImage imageNamed:@"music_down_sel"] forState:UIControlStateHighlighted];
    [downBt addTarget:self action:@selector(downAction) forControlEvents:UIControlEventTouchUpInside];
    [musicBgView addSubview:downBt];
    
}
- (void)playAction {
    if([_menuDelegate respondsToSelector:@selector(playMusic)]){
        [_menuDelegate playMusic];
    }
}
- (void)pauseAction {
    if([_menuDelegate respondsToSelector:@selector(pauseMusic)]){
        [_menuDelegate pauseMusic];
    }
}
- (void)stopAction {
    if([_menuDelegate respondsToSelector:@selector(stopMusic)]){
        [_menuDelegate stopMusic];
    }
}
- (void)upAction {
    if([_menuDelegate respondsToSelector:@selector(upMusic)]){
        [_menuDelegate upMusic];
    }
}
- (void)downAction {
    if([_menuDelegate respondsToSelector:@selector(downMusic)]){
        [_menuDelegate downMusic];
    }
}

#pragma mark 默认菜单
- (void)_createDefMenu:(UIView *)menuView {
    NSInteger index = menuView.tag - 1000;
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, menuView.height/2 - 16/2, KScreenWidth - 130, 16)];
    if([_menuDelegate menuMessage:index] != nil && ![[_menuDelegate menuMessage:index] isKindOfClass:[NSNull class]]){
        msgLabel.text = [_menuDelegate menuMessage:index];
    }
    msgLabel.textAlignment = NSTextAlignmentRight;
    msgLabel.font = [UIFont systemFontOfSize:17];
    if([_menuDelegate respondsToSelector:@selector(menuMessageColor:)]){
        msgLabel.textColor = [_menuDelegate menuMessageColor:index];
    }
    [menuView addSubview:msgLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTop:)];
    msgLabel.userInteractionEnabled = YES;
    [msgLabel addGestureRecognizer:tap];
}
- (void)textTop:(UITapGestureRecognizer *)tap {
    if([_menuDelegate respondsToSelector:@selector(didSelectMenu:)]){
        [_menuDelegate didSelectMenu:tap.view.tag - 3000];
        self.hidden = YES;
    }
}

#pragma mark Switch菜单
- (void)_createSwitchMenu:(UIView *)menuView {
    NSInteger index = menuView.tag - 1000;
    
    YQSwitch *yqSwtch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 80, menuView.height/2 - 40/2, 70, 40)];
    yqSwtch.tag = 4000 + index;
    yqSwtch.onText = @"ON";
    yqSwtch.offText = @"OFF";
    yqSwtch.backgroundColor = [UIColor clearColor];
    yqSwtch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    yqSwtch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    [yqSwtch addTarget:self action:@selector(onOrOffClick:) forControlEvents:UIControlEventValueChanged];
    if([_menuDelegate respondsToSelector:@selector(isSwitch:)]){
        yqSwtch.on = [_menuDelegate isSwitch:index];
    }
    
    [menuView addSubview:yqSwtch];
}
- (void)onOrOffClick:(YQSwitch *)yqSwtch {
    if([_menuDelegate respondsToSelector:@selector(switchState:withSwitch:)]){
        [_menuDelegate switchState:yqSwtch.tag - 4000 withSwitch:yqSwtch.isOn];
    }
}

#pragma mark Slider菜单
- (void)_createSlider:(UIView *)menuView {
    NSInteger index = menuView.tag - 1000;
    
    NSArray *imgs;
    if([_menuDelegate respondsToSelector:@selector(sliderImgs:)]){
        imgs = [_menuDelegate sliderImgs:index];
    }else {
        imgs = @[@"", @""];
    }
    
    //左右轨的图片
    UIImage *stetchLeftTrack;
    if(imgs != nil && imgs.count >= 1){
        stetchLeftTrack = [UIImage imageNamed:imgs[0]];
    }
    UIImage *stetchRightTrack;
    if(imgs != nil && imgs.count > 1){
        stetchRightTrack = [UIImage imageNamed:imgs[1]];
    }
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    YQSlider *sliderA = [[YQSlider alloc]initWithFrame:CGRectMake(KScreenWidth-255, 0, 240, 8)];
    sliderA.centerY = menuView.height/2;
    sliderA.backgroundColor = [UIColor clearColor];
    sliderA.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    sliderA.delegate = self;
    if(_menuDelegate && [_menuDelegate respondsToSelector:@selector(silderUnit:)]){
        sliderA.unitStr = [_menuDelegate silderUnit:index];
    }else {
        sliderA.unitStr = @"%";
    }
    if(_menuDelegate && [_menuDelegate respondsToSelector:@selector(sliderMinValue:)]){
        sliderA.minimumValue = [_menuDelegate sliderMinValue:index];
    }else {
        sliderA.minimumValue = 0;
    }
    if(_menuDelegate && [_menuDelegate respondsToSelector:@selector(sliderMaxValue:)]){
        sliderA.maxValue = [NSString stringWithFormat:@"%f", [_menuDelegate sliderMaxValue:index]];
    }

    if(_menuDelegate && [_menuDelegate respondsToSelector:@selector(silderLeftTitle:)] && [_menuDelegate respondsToSelector:@selector(silderRightTitle:)]){
        sliderA.leftTitleStr = [_menuDelegate silderLeftTitle:index];
        sliderA.rightTitleStr = [_menuDelegate silderRightTitle:index];
    }
    
    if([_menuDelegate respondsToSelector:@selector(sliderDefValue:)]){
        sliderA.value = [_menuDelegate sliderDefValue:index];
    }else {
        sliderA.value = 0;
    }
    sliderA.minimumValue = 0;
    sliderA.maximumValue = 1.0;
    sliderA.minimumValueImage = stetchLeftTrack;
    sliderA.maximumValueImage = stetchRightTrack;
    //滑块拖动时的事件
//    [sliderA addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //滑动拖动后的事件
    [sliderA addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [sliderA setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [sliderA setThumbImage:thumbImage forState:UIControlStateNormal];
    [menuView addSubview:sliderA];
}
- (void)sliderDragUp:(YQSlider *)slider {
    if([_menuDelegate respondsToSelector:@selector(sliderChangeValue:)]){
        [_menuDelegate sliderChangeValue:slider.value];
    }
}

-(void)minimumTrackBtnAction:(YQSlider *)slider
{
    if(slider.value <= 0){
        return;
    }else {
        slider.value = slider.value - slider.value/56;
        [self sliderDragUp:slider];
    }
}

-(void)maximumTrackBtnAction:(YQSlider *)slider
{
    if(slider.value >= 1){
        return;
    }else {
        slider.value = slider.value + slider.value/56;
        [self sliderDragUp:slider];
    }
}

#pragma mark 只包含图片菜单
- (void)_createImage:(UIView *)menuView {
    NSInteger index = menuView.tag - 1000;
    
    UIButton *imgBt = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize btSize = CGSizeMake(62, 62);
    if([_menuDelegate respondsToSelector:@selector(imageSize:)]){
        btSize = [_menuDelegate imageSize:index];
    }
    imgBt.frame = CGRectMake(KScreenWidth - btSize.width - 10, menuView.height/2 - btSize.width/2, btSize.width, btSize.width);
    if([_menuDelegate respondsToSelector:@selector(imageName:)]){
        if([UIImage imageNamed:[_menuDelegate imageName:index]] != nil){
            imgBt.tag = index + 2000;
            [imgBt setBackgroundImage:[UIImage imageNamed:[_menuDelegate imageName:index]] forState:UIControlStateNormal];
            [imgBt addTarget:self action:@selector(imgBtClick:) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:imgBt];
        }else {
            // 图片url
            imgBt.hidden = YES;
            UIImageView *parkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 198, imgBt.center.y - 64, 188, 128)];
            parkImgView.tag = index + 2000;
            [parkImgView sd_setImageWithURL:[NSURL URLWithString:[_menuDelegate imageName:index]] placeholderImage:[UIImage imageNamed:@"icon_no_picture"]];
            [menuView addSubview:parkImgView];
            
            UITapGestureRecognizer *showTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(parkImgClick:)];
            parkImgView.userInteractionEnabled = YES;
            [parkImgView addGestureRecognizer:showTap];
        }
    }
    
}
- (void)imgBtClick:(UIButton *)imgBt {
    self.hidden = YES;
    if([_menuDelegate respondsToSelector:@selector(didSelectMenu:)]){
        [_menuDelegate didSelectMenu:imgBt.tag - 2000];
    }
}

- (void)parkImgClick:(UITapGestureRecognizer *)tap {
    self.hidden = YES;
    if([_menuDelegate respondsToSelector:@selector(didSelectMenu:)]){
        [_menuDelegate didSelectMenu:tap.view.tag - 2000];
    }
}

#pragma mark 文本加图片菜单
- (void)_createTextImg:(UIView *)menuView {
    NSInteger index = menuView.tag - 1000;

    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(110, 0, KScreenWidth - 120, menuView.height)];
    bgView.tag = index + 3000;
    // 添加 label image
    [menuView addSubview:bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txImgTop:)];
    [bgView addGestureRecognizer:tap];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(bgView.width - 30, bgView.height/2 - 20/2, 20, 20)];
    if([_menuDelegate respondsToSelector:@selector(imageName:)]){
        imgView.image = [UIImage imageNamed:[_menuDelegate imageName:index]];
    }
    [bgView addSubview:imgView];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.height/2 - 16/2, bgView.width - 40, 16)];
    msgLabel.textAlignment = NSTextAlignmentRight;
    msgLabel.text = [_menuDelegate menuMessage:index];
    msgLabel.font = [UIFont systemFontOfSize:17];
    if([_menuDelegate respondsToSelector:@selector(menuMessageColor:)]){
        msgLabel.textColor = [_menuDelegate menuMessageColor:index];
    }
    [bgView addSubview:msgLabel];
    
}
- (void)txImgTop:(UITapGestureRecognizer *)tap {
    self.hidden = YES;
    if([_menuDelegate respondsToSelector:@selector(didSelectMenu:)]){
        [_menuDelegate didSelectMenu:tap.view.tag - 3000];
    }
}

#pragma mark 重载Menu
- (void)reloadMenuData {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    [self _initView];
    [self _createMenView];
    
    if(!_isInit){
        // 隐藏 显示加动画
        _menuBgView.hidden = NO;
        _isInit = YES;
        CGRect bgFrame = _menuBgView.frame;
        _menuBgView.frame = CGRectMake(bgFrame.origin.x, KScreenHeight, bgFrame.size.width, bgFrame.size.height);
        [UIView animateWithDuration:0.15 animations:^{
            _menuBgView.frame = bgFrame;
        }];
    }
}

#pragma mark 重写隐藏显示hidl方法
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    
    if(hidden){
        // 隐藏
        _isInit = NO;
    }else {
        // 显示
        _menuBgView.hidden = YES;   // 先隐藏菜单，刷新显示
    }
    
}

@end
