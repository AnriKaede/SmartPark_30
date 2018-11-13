//
//  YQSecondHeaderView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQSecondHeaderView : UIView

//路灯开启数
@property (nonatomic,strong) UILabel *openNumLab;

@property (nonatomic,strong) UILabel *openLab;

//故障数
@property (nonatomic,strong) UILabel *brokenNumLab;

@property (nonatomic,strong) UILabel *brokenLab;

@property (nonatomic,strong) UIImageView *lineView;

@end
