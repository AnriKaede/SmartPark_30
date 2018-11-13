//
//  MsgView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/14.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgView : UIImageView

@property (nonatomic,strong) UILabel *leftLab;
@property (nonatomic,strong) UILabel *leftNumLab;
@property (nonatomic,strong) UILabel *centerLab;
@property (nonatomic,strong) UILabel *centerNumLab;
@property (nonatomic,strong) UILabel *rightLab;
@property (nonatomic,strong) UILabel *rightNumLab;

@property (nonatomic,assign) NSInteger num;

@end
