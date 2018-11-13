//
//  SimilarValueCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "SimilarValueCell.h"

@implementation SimilarValueCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIImage *stetchLeftTrack= [UIImage imageNamed:@""];
//    UIImage *stetchRightTrack = [UIImage imageNamed:@""];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"Slider"];
    _similarSlider.backgroundColor = [UIColor clearColor];
    _similarSlider.frame = CGRectMake(92, (self.height - 10)/2, KScreenWidth - 92 - 44, 10);
    _similarSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"0068B8"];
    _similarSlider.unitStr = @"%";
    _similarSlider.value=0.9;
    _similarSlider.minimumValue=0.01;
    _similarSlider.maximumValue=1.0;
//    _similarSlider.minimumValueImage = stetchLeftTrack;
//    _similarSlider.maximumValueImage = stetchRightTrack;
    _similarSlider.minimumTrackImageName = @"_light_full_bg";
    _similarSlider.minTrackBtn.hidden = YES;
    _similarSlider.maxTrackBtn.hidden = YES;
    //滑动拖动后的事件
    [_similarSlider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    [_similarSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [_similarSlider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (void)sliderDragUp:(YQSlider *)yqSlider {
    
}

@end
