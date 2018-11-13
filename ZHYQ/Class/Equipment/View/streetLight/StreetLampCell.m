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
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setStreetLampSubModel:(StreetLampSubModel *)streetLampSubModel {
    _streetLampSubModel = streetLampSubModel;
    
    _lampNameLbael.text = streetLampSubModel.DEVICE_NAME;
    
    if(streetLampSubModel.isConSelect){
        _selBt.selected = YES;
    }else {
        _selBt.selected = NO;
    }
}

- (IBAction)selCon:(id)sender {
    if(_selConDelegate){
        [_selConDelegate selCon:_streetLampSubModel];
    }
}

@end
