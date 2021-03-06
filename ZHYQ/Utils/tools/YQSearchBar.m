//
//  YQSearchBar.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/29.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQSearchBar.h"

@interface YQSearchBar () <UITextFieldDelegate>

// placeholder 和icon 和 间隙的整体宽度
@property (nonatomic, assign) CGFloat placeholderWidth;

@end

// icon宽度
static CGFloat const searchIconW = 20.0;
// icon与placeholder间距
static CGFloat const iconSpacing = 10.0;
// 占位文字的字体大小
static CGFloat const placeHolderFont = 15.0;

@implementation YQSearchBar

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 设置背景图片
    if(_bgImage){
        [self setBackgroundImage:_bgImage];
    }else {
        // 添加渐变色
        UIImage *backImage = [NavGradient searchAddGradient:self];
//        [UIImage imageWithColor:[UIColor clearColor]];
        [self setBackgroundImage:backImage];
    }

    for (UIView *view in [self.subviews lastObject].subviews) {
        
        if ([view isKindOfClass:[UITextField class]]) {
                        
            UITextField *field = (UITextField *)view;
            // 重设field的frame
            field.frame = CGRectMake(15.0, 7.5, self.frame.size.width-30.0, self.frame.size.height-15.0);
            [field setBackgroundColor:[UIColor clearColor]];
            field.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            
            field.borderStyle = UITextBorderStyleNone;
            field.layer.cornerRadius = 2.0f;
            field.layer.masksToBounds = YES;
            
            // 设置占位文字字体颜色
            if(_labelColor){
                [field setValue:_labelColor forKeyPath:@"_placeholderLabel.textColor"];
            }else {
                [field setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
            }
            [field setValue:[UIFont systemFontOfSize:placeHolderFont] forKeyPath:@"_placeholderLabel.font"];
            
            if (@available(iOS 11.0, *)) {
                // 先默认居中placeholder
                [self setPositionAdjustment:UIOffsetMake((field.frame.size.width-self.placeholderWidth)/2, 0) forSearchBarIcon:UISearchBarIconSearch];
                self.searchTextPositionAdjustment = UIOffsetMake(5, 0);
            }
        }
    }
    
}

// 开始编辑的时候重置为靠左
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // 继续传递代理方法
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    if (@available(iOS 11.0, *)) {
        [self setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
    return YES;
}
// 结束编辑的时候设置为居中
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        [self.delegate searchBarShouldEndEditing:self];
    }
    if (@available(iOS 11.0, *)) {
        [self setPositionAdjustment:UIOffsetMake((textField.frame.size.width-self.placeholderWidth)/2, 0) forSearchBarIcon:UISearchBarIconSearch];
    }
    return YES;
}

// 计算placeholder、icon、icon和placeholder间距的总宽度
- (CGFloat)placeholderWidth {
    if (!_placeholderWidth) {
        CGSize size = [self.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:placeHolderFont]} context:nil].size;
        _placeholderWidth = size.width + iconSpacing + searchIconW;
    }
    return _placeholderWidth;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

