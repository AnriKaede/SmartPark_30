//
//  YQTextView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQTextView.h"

@interface YQTextView ()

@property(nonatomic,weak) UILabel *placeholderLabel;

@end

@implementation YQTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        //添加一个占位label
        UILabel * placeholderLabel = [[UILabel alloc] init];
        
        placeholderLabel.backgroundColor = [UIColor clearColor];
        //设置输入多行文字的时候可以换行
        placeholderLabel.numberOfLines = 0;
        
        [self addSubview:placeholderLabel];
        //赋值保存
        self.placeholderLabel = placeholderLabel;
        
        self.myPlaceholderColor = [UIColor grayColor];;
        
        self.font = [UIFont systemFontOfSize:15];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChang) name:UITextViewTextDidChangeNotification  object:self];
    }
    
    return self;
}

-(void)textDidChang
{
    self.placeholderLabel.hidden = self.hasText;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.placeholderLabel.y = 8;
    self.placeholderLabel.x =5;
    
    self.placeholderLabel.width = self.width -self.placeholderLabel.x * 2.0;
    
    CGSize maxSize = CGSizeMake(self.placeholderLabel.width, MAXFLOAT);
    
    self.placeholderLabel.height = [self.myPlaceholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.placeholderLabel.font} context:nil].size.height;
    
}

-(void)setMyPlaceholder:(NSString *)myPlaceholder
{
    _myPlaceholder = [myPlaceholder copy];
    
    self.placeholderLabel.text = myPlaceholder;
    
    [self setNeedsLayout];
}

-(void)setMyPlaceholderColor:(UIColor *)myPlaceholderColor
{
    _myPlaceholderColor =myPlaceholderColor;
    
    self.placeholderLabel.textColor = myPlaceholderColor;
}

-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeholderLabel.font=font;
    
    [self setNeedsLayout];
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    
    [self textDidChang];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self textDidChang];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:UITextViewTextDidChangeNotification];
}

@end
