//
//  BuildView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BuildView.h"

@implementation BuildView
{
    UIView *_buildView; // 建筑区域视图
    UIView *_floorView; // 楼层视图
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.height)];
    bgImgView.image = [UIImage imageNamed:@"dist_bg"];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    bgImgView.clipsToBounds = YES;
    [self addSubview:bgImgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, KScreenWidth - 20, 20)];
    titleLabel.tag = 3000;
    titleLabel.text = @"中通服天园研发大楼";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    // 建筑区域视图
    _buildView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.height - 200)/2, KScreenWidth, 200)];
    [self addSubview:_buildView];
    
    UIView *leftView = [self regionView:CGRectMake(KScreenWidth/2 - 100, 57, 86, 86) withTitle:@"东北电井"];
    [_buildView addSubview:leftView];
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftAction)];
    [leftView addGestureRecognizer:leftTap];
    
    UIView *rightView = [self regionView:CGRectMake(14 + KScreenWidth/2, 57, 86, 86) withTitle:@"东南电井"];
    [_buildView addSubview:rightView];
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightAction)];
    [rightView addGestureRecognizer:rightTap];
    
    // 楼层区域视图
    _floorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.height)];
    [self addSubview:_floorView];
    NSArray *titles = @[@"1F", @"2F", @"3F", @"4F", @"5F", @"6F", @"7F", @"8F", @"9F", @"10F"];
    [titles enumerateObjectsUsingBlock:^(NSString *floorTitle, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 4000 + idx;
        button.frame = CGRectMake(20*wScale, self.height - 30*idx - 90, 70, 26);
        button.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        [button setTitle:floorTitle forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(floorSelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_floorView addSubview:button];
    }];
}

- (UIView *)regionView:(CGRect)frame withTitle:(NSString *)title {
    UIView *regionView = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((86-22)/2, 15, 22, 29)];
    imgView.image = [UIImage imageNamed:@"dist_location"];
    [regionView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 8, 86, 30)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [regionView addSubview:label];
    
    return regionView;
}

#pragma mark 点击建筑区域
- (void)leftAction {
    if(_buildDelegate && [_buildDelegate respondsToSelector:@selector(buildLeft)]){
        [_buildDelegate buildLeft];
        UILabel *titleLabel = [self viewWithTag:3000];
        titleLabel.text = @"中通服天园研发大楼东北电井";
    }
}
- (void)rightAction {
    if(_buildDelegate && [_buildDelegate respondsToSelector:@selector(buildRight)]){
        [_buildDelegate buildRight];
        UILabel *titleLabel = [self viewWithTag:3000];
        titleLabel.text = @"中通服天园研发大楼东南电井";
    }
}

#pragma mark 选择楼层
- (void)floorSelAction:(UIButton *)floorBt {
    NSInteger index = floorBt.tag - 4000;
    if(_buildDelegate && [_buildDelegate respondsToSelector:@selector(buildFloor:)]){
        [_buildDelegate buildFloor:index];
    }
}

- (void)showBuild {
    _buildView.hidden = NO;
    _floorView.hidden = YES;
}
- (void)showFloor {
    _buildView.hidden = YES;
    _floorView.hidden = NO;
}

@end
