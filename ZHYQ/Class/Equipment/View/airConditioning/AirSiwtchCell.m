//
//  AirSiwtchCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirSiwtchCell.h"
#import "YQSwitch.h"

@interface AirSiwtchCell()<switchTapDelegate>

@end

@implementation AirSiwtchCell
{
    __weak IBOutlet UILabel *_airNameLabel;
//    __weak IBOutlet UILabel *_airMsgLabel;
    
    __weak IBOutlet UIButton *_openBt;
    __weak IBOutlet UIButton *_closeBt;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setFloorModel:(FloorModel *)floorModel {
    _floorModel = floorModel;
    
    _airNameLabel.text = floorModel.LAYER_NAME;
}

- (IBAction)openAction:(id)sender {
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 2.0 animations: ^{
            _openBt.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/2.0 animations: ^{
            _openBt.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:nil];
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定开启'%@'全部空调", _floorModel.LAYER_NAME] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(_airSwitchDelegate && [_airSwitchDelegate respondsToSelector:@selector(airSwitch:withOn:)]){
            [_airSwitchDelegate airSwitch:_floorModel withOn:YES];
        }
    }];
    
    [alertCon addAction:cancelAction];
    [alertCon addAction:openAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = self.contentView;
        alertCon.popoverPresentationController.sourceRect = self.contentView.bounds;
    }
    
    [[self viewController] presentViewController:alertCon animated:YES completion:nil];
}

- (IBAction)closeAction:(id)sender {
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 2.0 animations: ^{
            _closeBt.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/2.0 animations: ^{
            _closeBt.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    } completion:nil];
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定关闭'%@'全部空调", _floorModel.LAYER_NAME] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if(_airSwitchDelegate && [_airSwitchDelegate respondsToSelector:@selector(airSwitch:withOn:)]){
            [_airSwitchDelegate airSwitch:_floorModel withOn:NO];
        }
    }];
    
    [alertCon addAction:cancelAction];
    [alertCon addAction:openAction];
    
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = self.contentView;
        alertCon.popoverPresentationController.sourceRect = self.contentView.bounds;
    }
    
    [[self viewController] presentViewController:alertCon animated:YES completion:nil];
    
}

@end
