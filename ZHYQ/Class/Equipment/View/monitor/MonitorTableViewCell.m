//
//  MonitorTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorTableViewCell.h"
#import "YQSwitch.h"

#import "PlayVideoViewController.h"
#import "PlaybackViewController.h"

//#import "DHDataCenter.h"

@implementation MonitorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _selectView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
}

- (IBAction)playBtnAction:(id)sender {
    NSString *deviceType = @"";
    if(_indoorModel != nil && _indoorModel.TAGID != nil && ![_indoorModel.TAGID isKindOfClass:[NSNull class]]){
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _indoorModel.TAGID;
        deviceType = _indoorModel.DEVICE_TYPE;
    }else if(_mapModel != nil && _mapModel.TAGID != nil && ![_mapModel.TAGID isKindOfClass:[NSNull class]]){
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _mapModel.TAGID;
        deviceType = _mapModel.DEVICE_TYPE;
    }else {
        [[self viewController] showHint:@"无相机参数"];
        return;
    }
    
    if(_indoorModel.TAGID != nil && _indoorModel.TAGID.length > 6){
        NSString *careraID = [_indoorModel.TAGID substringWithRange:NSMakeRange(0, _indoorModel.TAGID.length - 6)];
        [self DSSPlayDeviceType:deviceType withCareraId:careraID];
    }else if(_mapModel.TAGID != nil && _mapModel.TAGID.length > 6){
        NSString *careraID = [_mapModel.TAGID substringWithRange:NSMakeRange(0, _mapModel.TAGID.length - 6)];
        [self DSSPlayDeviceType:deviceType withCareraId:careraID];
    }
    
}

- (void)DSSPlayDeviceType:(NSString *)deviceType withCareraId:(NSString *)careraID {
    #warning 大华SDK旧版本
    /*
    DeviceTreeNode* tasksGroup =  [DHDataCenter sharedInstance].CamerasGroups;
    
    [tasksGroup queryNodeByCareraId:careraID withBlock:^(DeviceTreeNode *node) {
        NSLog(@"在线离线状态：------- %d", node.bOnline);
        if(node.bOnline){
            // 在线
            PlayVideoViewController *playVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"PlayVideoViewController"];
            playVC.deviceType = deviceType;
            [[self viewController].navigationController pushViewController:playVC animated:YES];
        }else {
            // 离线
            [[self viewController] showHint:@"设备离线"];
            _statusLab.text = @"离线";
            _statusLab.textColor = [UIColor grayColor];
            _indoorModel.CAMERA_STATUS = @"2";
        }
    }];
     */
}

- (IBAction)playBlackBtnAction:(id)sender {
    NSString *deviceType = @"";
    if(_indoorModel != nil && _indoorModel.TAGID != nil && ![_indoorModel.TAGID isKindOfClass:[NSNull class]]){
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _indoorModel.TAGID;
        deviceType = _indoorModel.DEVICE_TYPE;
    }else if(_mapModel != nil && _mapModel.TAGID != nil && ![_mapModel.TAGID isKindOfClass:[NSNull class]]){
        #warning 大华SDK旧版本
//        [DHDataCenter sharedInstance].channelID = _mapModel.TAGID;
        deviceType = _mapModel.DEVICE_TYPE;
    }else {
        [[self viewController] showHint:@"无相机参数"];
        return;
    }
    
    PlaybackViewController *playVC = [[PlaybackViewController alloc] init];
    [[self viewController].navigationController pushViewController:playVC animated:YES];
}

-(void)setIndoorModel:(InDoorMonitorMapModel *)indoorModel
{
    _indoorModel = indoorModel;
    
    _monitorNameLab.text = [NSString stringWithFormat:@"%@",indoorModel.DEVICE_NAME];
    
    if([indoorModel.CAMERA_STATUS isEqualToString:@"1"]){
        // 正常
        _statusLab.text = @"正常开启中";
        _statusLab.textColor = [UIColor colorWithHexString:@"#189517"];
    }else if([indoorModel.CAMERA_STATUS isEqualToString:@"0"]){
        // 故障
        _statusLab.text = @"设备故障";
        _statusLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }if([indoorModel.CAMERA_STATUS isEqualToString:@"2"]){
        // 离线
        _statusLab.text = @"离线";
        _statusLab.textColor = [UIColor grayColor];
    }
    
    if ([indoorModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
        //        _monitorInfoLab.text = @"枪机";
    }else if ([indoorModel.DEVICE_TYPE isEqualToString:@"1-2"]){
        //        _monitorInfoLab.text = @"球机";
    }else{
        //        _monitorInfoLab.text = @"半球机";
    }
    
    
}

-(void)setMapModel:(MonitorMapModel *)mapModel
{
    _mapModel = mapModel;
    
    _monitorNameLab.text = [NSString stringWithFormat:@"%@",mapModel.DEVICE_NAME];
    
    if([mapModel.CAMERA_STATUS isEqualToString:@"1"]){
        // 正常
        _statusLab.text = @"正常开启中";
        _statusLab.textColor = [UIColor colorWithHexString:@"#189517"];
    }else if([mapModel.CAMERA_STATUS isEqualToString:@"0"]){
        // 故障
        _statusLab.text = @"设备故障";
        _statusLab.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }if([mapModel.CAMERA_STATUS isEqualToString:@"2"]){
        // 离线
        _statusLab.text = @"离线";
        _statusLab.textColor = [UIColor grayColor];
    }
    
    if ([mapModel.DEVICE_TYPE isEqualToString:@"1-1"]) {
        //        _monitorInfoLab.text = @"枪机";
    }else if ([mapModel.DEVICE_TYPE isEqualToString:@"1-2"]){
        //        _monitorInfoLab.text = @"球机";
    }else{
        //        _monitorInfoLab.text = @"半球机";
    }
    
}

-(void)_monitorSwitchClick
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
