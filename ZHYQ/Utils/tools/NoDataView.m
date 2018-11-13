//
//  NoDataView.m
//  ZSTC
//
//  Created by 魏唯隆 on 2017/4/19.
//  Copyright © 2017年 HNZT. All rights reserved.
//

#import "NoDataView.h"

@implementation NoDataView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake((KScreenWidth - 170)/2, (self.frame.size.height-240)/2, 170, 190)];
    bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgView];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake((bgView.width - 130)/2, 20, 130, 130)];
    _imgView.image = [UIImage imageNamed:@"new_no_date"];
    _imgView.userInteractionEnabled = YES;
    [bgView addSubview:_imgView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _imgView.bottom + 20, bgView.width, 30)];
    _label.text = @"暂时没有数据~";
    _label.userInteractionEnabled = YES;
    _label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    _label.font = [UIFont systemFontOfSize:17];
    _label.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_label];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReloadData)];
    [bgView addGestureRecognizer:tap];
    
}

-(void)tapReloadData
{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(reload)]) {
        [self.delegate reload];
    }
}

@end
