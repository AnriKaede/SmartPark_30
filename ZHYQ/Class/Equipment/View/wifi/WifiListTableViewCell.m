//
//  WifiListTableViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WifiListTableViewCell.h"
#import "YQSwitch.h"
#import "wifiSticalCenterViewController.h"

@implementation WifiListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _selectView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    
    // 暂时屏蔽开关
//    _wifiSwitch.enabled = NO;
//    _wifiSwitch.onTintColor = [UIColor lightGrayColor];
//    _wifiSwitch.tintColor = [UIColor lightGrayColor];
}

-(void)_waterOnOrOffClick:(id)sender
{
    YQSwitch *wifiSwitch = (YQSwitch *)sender;
    DLog(@"%d",wifiSwitch.on);
}

#pragma mark 室内地图
-(void)setModel:(InDoorWifiModel *)model
{
    _model = model;
    
    _wifiNameLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_NAME];
//    if ([model.WIFI_STATUS isEqualToString:@"1"]) {
//        _wifiSwitch.on = YES;
//    }else{
//        _wifiSwitch.on = NO;
//    }
    
    _locationNumLab.text = [NSString stringWithFormat:@"%@",model.DEVICE_ADDR];
    
}

#pragma mark 室外地图
-(void)setMapModel:(WifiMapModel *)mapModel
{
    _mapModel = mapModel;
    
    _wifiNameLab.text = [NSString stringWithFormat:@"%@",mapModel.DEVICE_NAME];
//    if ([mapModel.WIFI_STATUS isEqualToString:@"1"]) {
//        _wifiSwitch.on = YES;
//    }else{
//        _wifiSwitch.on = NO;
//    }
    
    _locationNumLab.text = [NSString stringWithFormat:@"%@",mapModel.DEVICE_ADDR];
    
}

- (void)setWifiInfoModel:(WifiInfoModel *)wifiInfoModel {
    _wifiInfoModel = wifiInfoModel;
    
    _netSepNumLab.text = [NSString stringWithFormat:@"%@", [self speedValueStr:wifiInfoModel.recv.doubleValue]];
    _sendNumLab.text = [NSString stringWithFormat:@"%@", [self speedValueStr:wifiInfoModel.send.doubleValue]];
    _userNumLab.text = [NSString stringWithFormat:@"%@", wifiInfoModel.usercount];
}

- (NSString *)speedValueStr:(double)speed {
    NSString *speedStr;
    if(speed < 1024){
        // b
        speedStr = [NSString stringWithFormat:@"%.2f b", speed];
    }else if(speed > 1024 && speed < 1024*1024){
        // kb
        speedStr = [NSString stringWithFormat:@"%.2f kb", speed/1024.00];
    }else {
        // M
        speedStr = [NSString stringWithFormat:@"%.2f M", speed/(1024.00*1024.00)];
    }
    return speedStr;
}

- (IBAction)goUser:(id)sender {
    wifiSticalCenterViewController *wifiStiVc = [[wifiSticalCenterViewController alloc] init];
    wifiStiVc.wifiInfoModel = _wifiInfoModel;
    if(_model != nil){
        wifiStiVc.inDoorWifiModel = _model;
    }else if (_mapModel != nil) {
        wifiStiVc.inDoorWifiModel = (InDoorWifiModel *)_mapModel;
    }
    [[self viewController].navigationController pushViewController:wifiStiVc animated:YES];
}

- (IBAction)restartAction:(id)sender {
    if(_wifiConDelegate != nil && [_wifiConDelegate respondsToSelector:@selector(wifiConType:)]){
        [_wifiConDelegate wifiConType:0];
    }
}
- (IBAction)openAction:(id)sender {
    if(_wifiConDelegate != nil && [_wifiConDelegate respondsToSelector:@selector(wifiConType:)]){
        [_wifiConDelegate wifiConType:1];
    }
}
- (IBAction)closeAction:(id)sender {
    if(_wifiConDelegate != nil && [_wifiConDelegate respondsToSelector:@selector(wifiConType:)]){
        [_wifiConDelegate wifiConType:2];
    }
}


@end
