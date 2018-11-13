//
//  WarnCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WarnCell.h"

@implementation WarnCell
{
    __weak IBOutlet UILabel *_titleLabel;
    
    __weak IBOutlet UILabel *_stateLabel;
    
    __weak IBOutlet UIImageView *_flagImgView;
    
    __weak IBOutlet NSLayoutConstraint *_imgViewWidth;
    __weak IBOutlet NSLayoutConstraint *_imgViewLeftWidth;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setWranBillStyle:(WranBillStyle)wranBillStyle {
    _wranBillStyle = wranBillStyle;
    
    if(wranBillStyle == WranUnDeal){
        _stateLabel.text = @"立即处理";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }else if(wranBillStyle == WranUnSend){
        _stateLabel.text = @"立即派单";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    }else if(wranBillStyle == WranRepairing){
        _stateLabel.text = @"查看详情";
        _stateLabel.textColor = [UIColor colorWithHexString:@"#189517"];
    }
}

- (void)setWranModel:(WranUndealModel *)wranModel {
    _wranModel = wranModel;
    
    _titleLabel.text = [NSString stringWithFormat:@"%@ 故障", wranModel.deviceName];
}

@end
