//
//  WarnCutView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WarnCutView.h"

@implementation WarnCutView
{
    NSArray *_titles;
    UIView *_lineView;
    CGFloat itemWidth;
}

- (instancetype)initWithFrame:(CGRect)frame withTitleDatas:(NSArray *)titles {
    self = [super initWithFrame:frame];
    if(self){
        _titles = titles;
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
//    self.mutableCopy
    
    itemWidth = KScreenWidth/_titles.count;
    [_titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth * idx, 0, itemWidth, self.height - 5)];
        label.text = title;
        label.tag = 2000 + idx;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        UITapGestureRecognizer *cutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cutAction:)];
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:cutTap];
    }];
    
    // 下方current标题
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 5, itemWidth, 5)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self addSubview:_lineView];
}

- (void)cutAction:(UITapGestureRecognizer *)tap {
    NSInteger viewTag = tap.view.tag - 2000;
    [UIView animateWithDuration:0.3 animations:^{
        _lineView.frame = CGRectMake(itemWidth*viewTag, _lineView.top, itemWidth, 5);
    }];
    
    if(_cutDelegate && [_cutDelegate respondsToSelector:@selector(cutIndex:)]){
        [_cutDelegate cutIndex:viewTag];
    }
}

- (void)setSelIndex:(NSInteger)index withAnimation:(BOOL)Animation {
    if(Animation){
        [UIView animateWithDuration:0.3 animations:^{
            _lineView.frame = CGRectMake(KScreenWidth/_titles.count * index, _lineView.frame.origin.y, _lineView.width, _lineView.height);
        }];
    }else {
        _lineView.frame = CGRectMake(KScreenWidth/_titles.count * index, _lineView.frame.origin.y, _lineView.width, _lineView.height);
    }
}

@end
