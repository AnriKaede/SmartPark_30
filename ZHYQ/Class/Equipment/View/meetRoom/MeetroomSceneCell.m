//
//  MeetroomSceneCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MeetroomSceneCell.h"
#import "YQSwitch.h"

@interface MeetroomSceneCell ()<switchTapDelegate>
{
    __weak IBOutlet UIImageView *_modelImgView;
    __weak IBOutlet UILabel *_modelName;
    
}
@end

@implementation MeetroomSceneCell
{
    YQSwitch *_yqSwitch;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _creteView];
    }
    return self;
}
- (void)_creteView {
    _yqSwitch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 75, 22, 60, 30)];
    _yqSwitch.onText = @"ON";
    _yqSwitch.offText = @"OFF";
    _yqSwitch.backgroundColor = [UIColor clearColor];
    _yqSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _yqSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
//    [_yqSwitch addTarget:self action:@selector(_waterOnOrOffClick:) forControlEvents:UIControlEventValueChanged];
    _yqSwitch.switchDelegate = self;
    [self.contentView addSubview:_yqSwitch];
}

- (void)switchTap:(BOOL)on {
    if(_yqSwitch.on){
//        _sceneOnOffModel.onOff = @1;
    }else {
//        _sceneOnOffModel.onOff = @0;
    }
    if(_sceneDelegate && [_sceneDelegate respondsToSelector:@selector(conScene:withOpen:)]){
        [_sceneDelegate conScene:_sceneOnOffModel withOpen:_yqSwitch.on];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (void)setSceneOnOffModel:(SceneOnOffModel *)sceneOnOffModel {
    _sceneOnOffModel = sceneOnOffModel;
    
    if(sceneOnOffModel.onOff.integerValue == 0){
        // 关闭
        [_yqSwitch setOn:NO animated:YES];
        _yqSwitch.enabled = YES;
    }else {
        // 打开
        [_yqSwitch setOn:YES animated:YES];
        _yqSwitch.enabled = NO;
    }
    
    if(sceneOnOffModel.modelName != nil && ![sceneOnOffModel.modelName isKindOfClass:[NSNull class]]){
        _modelName.text = sceneOnOffModel.modelName;
    }else {
        _modelName.text = @"-";
    }
    if([sceneOnOffModel.modelId isEqualToString:@"meeting"]){
        // 会议模式
        _modelImgView.image = [UIImage imageNamed:@"meetroom_mode_meeting_icon"];
    }else if([sceneOnOffModel.modelId isEqualToString:@"outing"]){
        // 离场模式
        _modelImgView.image = [UIImage imageNamed:@"mode_leaving_icon"];
    }else if([sceneOnOffModel.modelId isEqualToString:@"shadowing"]){
        // 投影模式
        _modelImgView.image = [UIImage imageNamed:@"meetroom_mode_display_icon"];
    }else {
        _modelImgView.image = [UIImage imageNamed:@"mode_self_icon"];
    }
}

@end
