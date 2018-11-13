//
//  OpenDoorAreaCltViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenDoorAreaCltViewCell.h"

@implementation OpenDoorAreaCltViewCell
{
    __weak IBOutlet UIImageView *_typeImagView;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _areaName.selected = NO;

//    [_areaName setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"F3F3F3"]] forState:UIControlStateNormal];
//    [_areaName setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"1B82D1"]] forState:UIControlStateSelected];
}

- (IBAction)areaBtnClick:(id)sender {
    
//    UIButton *btn = (UIButton *)sender;
//    btn.selected = !btn.selected;
    
}

- (void)setOpenDoorModel:(OpenDoorModel *)openDoorModel {
    _openDoorModel = openDoorModel;
    
    [_areaName setTitle:openDoorModel.DEVICE_NAME forState:UIControlStateNormal];
    
//    _areaName.selected = YES;
    
    /*
    if ([openDoorModel.DEVICE_TYPE isEqualToString:@"4"]) {
        _typeImagView.image = [UIImage imageNamed:@"info_door_close"];
    }else if ([openDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        _typeImagView.image = [UIImage imageNamed:@"gatemachine_close"];
    }else {
        _typeImagView.image = [UIImage imageNamed:@""];
    }
     */
    
    if([openDoorModel.DEVICE_TYPE isEqualToString:@"4-1"]){
        _typeImagView.image = [UIImage imageNamed:@"gatemachine_close"];
    }else {
        _typeImagView.image = [UIImage imageNamed:@"info_door_close"];
    }
}


@end
