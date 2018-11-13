//
//  DistributorCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/8/15.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "DistributorCell.h"

@implementation DistributorCell
{
    __weak IBOutlet UILabel *_hisHeightLabel;   //历史最高温度：60℃
    __weak IBOutlet UILabel *_ATempLabel;   // A相温度：27℃
    __weak IBOutlet UILabel *_BTempLabel;
    __weak IBOutlet UILabel *_CTempLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDistributorModel:(DistributorModel *)distributorModel {
    _distributorModel = distributorModel;
    
    _hisHeightLabel.text = [NSString stringWithFormat:@"历史最高温度：%@℃", distributorModel.hisHeightTemp];
    
    _ATempLabel.text = [NSString stringWithFormat:@"A相温度：%@℃", distributorModel.ATemp];
    _BTempLabel.text = [NSString stringWithFormat:@"B相温度：%@℃", distributorModel.BTemp];
    _CTempLabel.text = [NSString stringWithFormat:@"C相温度：%@℃", distributorModel.CTemp];
}

@end
