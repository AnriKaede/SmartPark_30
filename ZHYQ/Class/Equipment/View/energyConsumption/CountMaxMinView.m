//
//  CountMaxMinView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CountMaxMinView.h"

@implementation CountMaxMinView
{
    UILabel *_maxPartNameLabel;
    UILabel *_maxNumLabel;
    
    UILabel *_minPartNameLabel;
    UILabel *_minNumLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width/2 - 0.5, 0, 1, self.height)];
    lineImgView.image = [UIImage imageNamed:@"LED_seperateline_blue"];
    lineImgView.alpha = 0.8;
    [self addSubview:lineImgView];
    
    _maxPartNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, 30, KScreenWidth/2 - 2, 25)];
    _maxPartNameLabel.textAlignment = NSTextAlignmentCenter;
    _maxPartNameLabel.textColor = [UIColor blackColor];
    _maxPartNameLabel.font = [UIFont systemFontOfSize:21];
    [self addSubview:_maxPartNameLabel];
    
    UILabel *maxLabel = [[UILabel alloc] init];
    maxLabel.frame = CGRectMake(1,_maxPartNameLabel.bottom + 24,KScreenWidth/2 - 2,17);
    maxLabel.textAlignment = NSTextAlignmentCenter;
    maxLabel.text = @"能耗最大区域";
    maxLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    [self addSubview:maxLabel];
    
    _maxNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, maxLabel.bottom + 26, KScreenWidth/2 - 2, 25)];
    _maxNumLabel.textAlignment = NSTextAlignmentCenter;
    _maxNumLabel.textColor = [UIColor blackColor];
    _maxNumLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_maxNumLabel];
    
    UILabel *maxNLabel = [[UILabel alloc] init];
    maxNLabel.frame = CGRectMake(1,_maxNumLabel.bottom + 26,KScreenWidth/2 - 2,17);
    maxNLabel.textAlignment = NSTextAlignmentCenter;
    maxNLabel.text = @"能耗用量";
    maxNLabel.textColor = [UIColor colorWithHexString:@"#FF4359"];
    [self addSubview:maxNLabel];
    
    
    _minPartNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2 + 1, 30, KScreenWidth/2 - 2, 25)];
    _minPartNameLabel.textAlignment = NSTextAlignmentCenter;
    _minPartNameLabel.textColor = [UIColor blackColor];
    _minPartNameLabel.font = [UIFont systemFontOfSize:21];
    [self addSubview:_minPartNameLabel];
    
    UILabel *minLabel = [[UILabel alloc] init];
    minLabel.frame = CGRectMake(KScreenWidth/2 + 1,_maxPartNameLabel.bottom + 24,KScreenWidth/2 - 2,17);
    minLabel.textAlignment = NSTextAlignmentCenter;
    minLabel.text = @"能耗最小区域";
    minLabel.textColor = [UIColor colorWithHexString:@"#189517"];
    [self addSubview:minLabel];
    
    _minNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth/2 + 1, maxLabel.bottom + 26, KScreenWidth/2 - 2, 25)];
    _minNumLabel.textAlignment = NSTextAlignmentCenter;
    _minNumLabel.textColor = [UIColor blackColor];
    _minNumLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:_minNumLabel];
    
    UILabel *minNLabel = [[UILabel alloc] init];
    minNLabel.frame = CGRectMake(KScreenWidth/2 + 1,_minNumLabel.bottom + 26,KScreenWidth/2 - 2,17);
    minNLabel.textAlignment = NSTextAlignmentCenter;
    minNLabel.text = @"能耗用量";
    minNLabel.textColor = [UIColor colorWithHexString:@"#189517"];
    [self addSubview:minNLabel];
    
}

#pragma mark 填充数据
- (void)setMaxPartName:(NSString *)maxPartName {
    _maxPartName = maxPartName;
    _maxPartNameLabel.text = maxPartName;
}
- (void)setMaxNum:(NSString *)maxNum {
    _maxNum = maxNum;
    _maxNumLabel.text = maxNum;
}

- (void)setMinPartName:(NSString *)minPartName {
    _minPartName = minPartName;
    _minPartNameLabel.text = minPartName;
}
- (void)setMinNum:(NSString *)minNum {
    _minNum = minNum;
    _minNumLabel.text = minNum;
}

@end
