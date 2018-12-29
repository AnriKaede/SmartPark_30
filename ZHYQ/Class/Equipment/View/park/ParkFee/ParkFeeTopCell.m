//
//  ParkFeeTopCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeTopCell.h"

@implementation ParkFeeTopCell
{
    __weak IBOutlet UIView *_topBgView;
    __weak IBOutlet UIView *_ringBgView;
    
    __weak IBOutlet UIView *_bgView;
    
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UIView *_ratioLabel;    // %
    __weak IBOutlet UIImageView *_upDownImgView;
    
    __weak IBOutlet UILabel *_wechatLabel;
    __weak IBOutlet UILabel *_alipayLabel;
    __weak IBOutlet UILabel *_yipayLabel;
    __weak IBOutlet UILabel *_cashLabel;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    NSArray *btTitles = @[@"日", @"周", @"月"];
    //    NSArray *btTitles = @[@"日"];
    [btTitles enumerateObjectsUsingBlock:^(NSString *btTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *dateBt = [UIButton buttonWithType:UIButtonTypeCustom];
        dateBt.frame = CGRectMake(KScreenWidth - 130 + idx*40, 10, 40, 25);
        //        dateBt.frame = CGRectMake(KScreenWidth - 50 + idx*40, 10, 40, 25);
        [dateBt setTitle:btTitle forState:UIControlStateNormal];
        dateBt.tag = 100 + idx;
        dateBt.layer.borderColor = [UIColor colorWithHexString:@"#D1E6F6"].CGColor;
        dateBt.layer.borderWidth = 1;
        if(idx == 0){
            dateBt.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [dateBt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            dateBt.backgroundColor = [UIColor clearColor];
            [dateBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        [dateBt addTarget:self action:@selector(dateFilterAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:dateBt];
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _topBgView.backgroundColor = CNavBgColor;
    _bgView.backgroundColor = CNavBgColor;
    
    _bgView.layer.cornerRadius = _bgView.width/2;
    _bgView.backgroundColor = [UIColor clearColor];
    
    _ringBgView.layer.cornerRadius = _ringBgView.width/2;
    _ringBgView.backgroundColor = [UIColor clearColor];
    _ringBgView.layer.borderColor = [UIColor colorWithHexString:@"5BD3FF"].CGColor;
    _ringBgView.layer.borderWidth = 5;
    
    // 添加渐变色
    [NavGradient viewAddGradient:_topBgView];
}

#pragma mark 柱状图按日期筛选
- (void)dateFilterAction:(UIButton *)dateBt {
    [self changeBtState:dateBt];
    
    switch (dateBt.tag - 100) {
        case 0:
            // 日
            break;
        case 1:
            // 周
            break;
        case 2:
            // 月
            break;
            
    }
}
- (void)changeBtState:(UIButton *)dateBt {
    for (int i=0; i<3; i++) {
        UIButton *button = [_bgView viewWithTag:100 + i];
        if(button == dateBt){
            button.backgroundColor = [UIColor colorWithHexString:@"#D1E6F6"];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    if(dateBt.tag - 100 == 0){
        [self filter:FilterDay];
    }else if(dateBt.tag - 100 == 1){
        [self filter:FilterWeek];
    }else if(dateBt.tag - 100 == 2){
        [self filter:FilterMonth];
    }
    
}
- (void)filter:(FilterDateStyle)style {
    if(_filterDelegate && [_filterDelegate respondsToSelector:@selector(filterDelegate:)]){
        [_filterDelegate filterDelegate:style];
    }
}

@end
