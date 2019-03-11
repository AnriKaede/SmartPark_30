//
//  LEDSendTypeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/4.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDSendTypeCell.h"

@implementation LEDSendTypeCell
{
    __weak IBOutlet UILabel *_screenTypeLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setScreenType:(NSString *)screenType {
    _screenType = screenType;
    
    if([screenType isEqualToString:@"dengGan"]){
        _screenTypeLabel.text = @"灯杆屏";
    }else if([screenType isEqualToString:@"other"]){
        _screenTypeLabel.text = @"其他屏";
    }else {
        _screenTypeLabel.text = @"";
    }
}

@end
