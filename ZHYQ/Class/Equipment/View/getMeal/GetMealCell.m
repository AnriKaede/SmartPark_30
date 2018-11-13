//
//  GetMealCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "GetMealCell.h"

@implementation GetMealCell
{
    __weak IBOutlet UIView *_bgView;
    
    __weak IBOutlet UILabel *_numLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.borderColor = [UIColor colorWithHexString:@"#DCDCDC"].CGColor;
    _bgView.layer.borderWidth = 1;
    
}

- (void)setNumStr:(NSString *)numStr {
    _numStr = numStr;
    
    _numLabel.text = [NSString stringWithFormat:@"%@号", numStr];
}

- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    
    if(isSelect){
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#f6fbff"];
        _bgView.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
        _bgView.layer.borderWidth = 1;
        _numLabel.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    }else {
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.borderColor = [UIColor colorWithHexString:@"#DCDCDC"].CGColor;
        _bgView.layer.borderWidth = 1;
        _numLabel.textColor = [UIColor blackColor];
    }
}

@end
