//
//  YQInputView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "YQInputView.h"

// 自定义将RGB转换成UIColor
#define HJRGBA(r,g,b,a)  [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

@implementation YQInputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI{
    
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.text = @"详细内容";
    contentLab.font = [UIFont systemFontOfSize:15];
    contentLab.textAlignment = NSTextAlignmentLeft;
    contentLab.textColor = [UIColor blackColor];
    contentLab.frame = CGRectMake(10, 20, 80, 15);
    [self addSubview:contentLab];
    
    self.frame = CGRectMake(0, 0, KScreenWidth, 250);
    _textV = [[UITextView alloc]init];
    _textV.frame = CGRectMake(89, 10, KScreenWidth - 95, 240);
    _textV.font = [UIFont systemFontOfSize:15];
    [self addSubview:_textV];
    
    _placeholerLabel = [[UILabel alloc]init];
    _placeholerLabel.frame = CGRectMake(3, 7, KScreenWidth, 22);
    _placeholerLabel.text = @"请填写需要发布的内容";
    _placeholerLabel.textColor = HJRGBA(204, 204, 204, 1.0);
    _placeholerLabel.font = [UIFont systemFontOfSize:15];
    [_textV addSubview:_placeholerLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, KScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [self addSubview:lineView];
}

@end
