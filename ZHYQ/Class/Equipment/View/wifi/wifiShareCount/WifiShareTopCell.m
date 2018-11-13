//
//  WifiShareTopCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/26.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WifiShareTopCell.h"
#import "wifiSticalCenterViewController.h"
#import "WifiCountTypeModel.h"

@implementation WifiShareTopCell
{
    __weak IBOutlet UIView *_topBgView;
    __weak IBOutlet UIView *_ringBgView;
    
    __weak IBOutlet UIView *_bgView;
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UIView *_ratioLabel;    // %
    __weak IBOutlet UIImageView *_upDownImgView;
    
    __weak IBOutlet UILabel *_appleLabel;
    __weak IBOutlet UILabel *_andriodLabel;
    __weak IBOutlet UILabel *_computerLabel;
    __weak IBOutlet UILabel *_otherLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _topBgView.backgroundColor = CNavBgColor;
    _bgView.backgroundColor = CNavBgColor;
    
    _ringBgView.layer.cornerRadius = _ringBgView.width/2;
    _bgView.layer.cornerRadius = _bgView.width/2;
}

- (IBAction)listAction:(id)sender {
    wifiSticalCenterViewController *wifiStiVc = [[wifiSticalCenterViewController alloc] init];
    wifiStiVc.isALl = YES;
    [[self viewController].navigationController pushViewController:wifiStiVc animated:YES];
}

- (void)setClientData:(NSArray *)clientData {
    _clientData = clientData;
    
    [clientData enumerateObjectsUsingBlock:^(WifiCountTypeModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.clientType isEqualToString:@"苹果移动终端"]){
            _appleLabel.text = [NSString stringWithFormat:@"%@", model.userCount];
        }else if([model.clientType isEqualToString:@"安卓移动终端"]){
            _andriodLabel.text = [NSString stringWithFormat:@"%@", model.userCount];
        }else if([model.clientType isEqualToString:@"笔记本终端"]){
            _computerLabel.text = [NSString stringWithFormat:@"%@", model.userCount];
        }else if([model.clientType isEqualToString:@"其他设备端"]){
            _otherLabel.text = [NSString stringWithFormat:@"%@", model.userCount];
        }
    }];
}

- (void)setAllUserCount:(NSString *)allUserCount {
    _allUserCount = allUserCount;
    
    _numLabel.text = [NSString stringWithFormat:@"%@", allUserCount];
}

@end
