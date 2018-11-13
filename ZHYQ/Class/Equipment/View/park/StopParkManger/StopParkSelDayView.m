//
//  StopParkSelDayView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "StopParkSelDayView.h"

@interface StopParkSelDayView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIPickerView *_pickerView;
    NSMutableArray *_pickData;
    NSString *_selDay;
}
@end

@implementation StopParkSelDayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        _selDay = @"4";
        _pickData = @[].mutableCopy;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.hidden = YES;
    
    // 加载数据
    for (int i=1; i<=30; i++) {
        [_pickData addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    bgView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self addSubview:bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selCertain)];
    [bgView addGestureRecognizer:tap];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, KScreenHeight - 237 - kTopHeight, KScreenWidth, 237)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_pickerView];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 49)];
    msgLabel.backgroundColor = [UIColor whiteColor];
    msgLabel.text = @"请选择超过天数";
    msgLabel.textColor = [UIColor blackColor];
    msgLabel.font = [UIFont systemFontOfSize:17];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    [_pickerView addSubview:msgLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, KScreenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#BEBEBE"];
    [_pickerView addSubview:lineView];
    
}
- (void)selMsg {
    
}

- (void)selCertain {
    if(_selDayDelegate && [_selDayDelegate respondsToSelector:@selector(selDay:)]){
        [_selDayDelegate selDay:_selDay];
    }
    self.hidden = YES;
}

#pragma mark UIPickerView协议
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickData.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickData[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selDay = _pickData[row];
}

#pragma mark 显示
- (void)showView:(NSInteger)index {
    self.hidden = NO;
    [_pickerView selectRow:index inComponent:0 animated:YES];
}

@end
