//
//  EquipmentCollectionViewCell.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EquipmentCollectionViewCell.h"

@interface EquipmentCollectionViewCell()
{
    
}

@end

@implementation EquipmentCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        [self _initView];
        
    }
    
    return self;
}

-(void)_initView
{
    
    [self.contentView addSubview:self.topImageView];
    self.topImageView.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLab];
}

-(UIImageView *)topImageView
{
    if (_topImageView == nil) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.frame = CGRectMake((self.contentView.frame.size.width - 40)/2, 0, 40, self.contentView.frame.size.height-20);
    }
    return _topImageView;
}

-(UILabel *)titleLab
{
    if (_titleLab == nil) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.frame = CGRectMake(0, CGRectGetMaxY(_topImageView.frame), self.contentView.frame.size.width, 20);
    }
    return _titleLab;
}

@end
