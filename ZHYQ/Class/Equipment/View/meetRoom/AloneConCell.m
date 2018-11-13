//
//  AloneConCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/17.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AloneConCell.h"
#import "YQSwitch.h"

@interface AloneConCell() <switchTapDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UILabel *typeNameLab;

@property (weak, nonatomic) IBOutlet YQSwitch *singleCtrlSwitch;
@end

@implementation AloneConCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _singleCtrlSwitch.onText = @"ON";
    _singleCtrlSwitch.offText = @"OFF";
    _singleCtrlSwitch.on = YES;
    _singleCtrlSwitch.backgroundColor = [UIColor clearColor];
    _singleCtrlSwitch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
    _singleCtrlSwitch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    _singleCtrlSwitch.switchDelegate = self;
}

-(void)setModel:(MeetRoomModel *)model
{
    _model = model;
    
    // 图片
    if([model.DEVICE_TYPE isEqualToString:@"18-1"]){
        _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([model.DEVICE_TYPE isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([model.DEVICE_TYPE isEqualToString:@"19-1"]){
        _typeImageView.image = [UIImage imageNamed:@"meetroom_screen"];
    }else if([model.DEVICE_TYPE isEqualToString:@"19"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_curtain"];
    }else if([model.DEVICE_TYPE isEqualToString:@"20"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_scene"];
    }
    
    _singleCtrlSwitch.enabled = YES;
    if([model.EQUIP_STATUS isEqualToString:@"1"]){  // 开启
        _singleCtrlSwitch.on = YES;
    }else if([model.EQUIP_STATUS isEqualToString:@"2"]){  // 离线
        _singleCtrlSwitch.on = NO;
    }else if([model.EQUIP_STATUS isEqualToString:@"1"]){  // 故障
        _singleCtrlSwitch.on = NO;
        //        _singleCtrlSwitch.enabled = NO;
    }
    
    _typeNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
    
}

-(void)setSceneModel:(SceneEquipmentModel *)sceneModel
{
    _sceneModel = sceneModel;
    
    // 图片
    if([sceneModel.deviceType isEqualToString:@"18-1"]){
        _typeImageView.image = [UIImage imageNamed:@"筒灯"];
    }else if([sceneModel.deviceType isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([sceneModel.deviceType isEqualToString:@"18-3"]){
        _typeImageView.image = [UIImage imageNamed:@"灯箱"];
    }else if([sceneModel.deviceType isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([sceneModel.deviceType isEqualToString:@"18-2"]){
        _typeImageView.image = [UIImage imageNamed:@"灯带"];
    }else if([sceneModel.deviceType isEqualToString:@"19-1"]){
        _typeImageView.image = [UIImage imageNamed:@"meetroom_screen"];
    }else if([sceneModel.deviceType isEqualToString:@"19"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_curtain"];
    }else if([sceneModel.deviceType isEqualToString:@"20"]){
        _typeImageView.image = [UIImage imageNamed:@"scene_edit_scene"];
    }
    
    _singleCtrlSwitch.enabled = YES;
    if([sceneModel.tagStatus isEqualToString:@"ON"]){  // 开启
        _singleCtrlSwitch.on = YES;
    }else if([sceneModel.tagStatus isEqualToString:@"OFF"]){  // 离线
        _singleCtrlSwitch.on = NO;
    }
    
    _typeNameLab.text = [NSString stringWithFormat:@"%@",sceneModel.tagName];
    
}

- (void)switchTap:(BOOL)on {
    if(_singleCtrlSwitch.on){
        // 打开
//        _model.EQUIP_STATUS = @"1";
    }else {
        // 关闭
//        _model.EQUIP_STATUS = @"0";
    }
    if(_aloneDelegate && [_aloneDelegate respondsToSelector:@selector(aloneCon:withOpen:)]){
        [_aloneDelegate aloneCon:_model withOpen:_singleCtrlSwitch.on];
    }
}

@end
