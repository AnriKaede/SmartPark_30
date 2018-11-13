//
//  ScanNoDataView.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ScanNoDataView.h"

@implementation ScanNoDataView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self _initView];
    }
    return self;
}

- (void)_initView {
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake((self.width - 180)/2 , (self.height - 200)/2, 180, 200)];
    [self addSubview:centerView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((centerView.width - 104)/2, 0, 104, 116)];
    imgView.image = [UIImage imageNamed:@"scan_nodata"];
    [centerView addSubview:imgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 35, centerView.width, 20)];
    label.text = @"无该设备相关信息";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [centerView addSubview:label];
    
}

@end
