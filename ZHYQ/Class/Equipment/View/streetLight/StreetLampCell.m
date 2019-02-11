//
//  StreetLampCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StreetLampCell.h"

@implementation StreetLampCell
{
    __weak IBOutlet UILabel *_lampNameLbael;
    __weak IBOutlet UIButton *_selBt;
    
    __weak IBOutlet UIImageView *_lampImgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setStreetLampSubModel:(StreetLampSubModel *)streetLampSubModel {
    _streetLampSubModel = streetLampSubModel;
    
    if(_streetLampSubModel.isColor){
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F5FDFF"];
    }else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    _lampNameLbael.text = streetLampSubModel.DEVICE_NAME;
    
    if(streetLampSubModel.isConSelect){
        _selBt.selected = YES;
    }else {
        _selBt.selected = NO;
    }
    
    if([streetLampSubModel.DEVICE_TYPE isEqualToString:@"55-2"]){
        _lampImgView.image = [UIImage imageNamed:@"street_lamp_flower_icon"];
    }else {
        _lampImgView.image = [UIImage imageNamed:@"street_lamp_icon"];
    }
}

- (IBAction)selCon:(id)sender {
    if(_selConDelegate){
        [_selConDelegate selCon:_streetLampSubModel];
    }
}

@end
