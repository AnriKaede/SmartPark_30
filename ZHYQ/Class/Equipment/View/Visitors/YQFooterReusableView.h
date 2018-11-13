//
//  YQFooterReusableView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQFooterReusableView : UICollectionReusableView

@property (nonatomic,strong) UILabel *leaveTimeLab;

@property (nonatomic,strong) UILabel *arriveTimeLab;

@property (nonatomic,strong) UILabel *leaveTimeDetailLab;

@property (nonatomic,strong) UILabel *arriveTimeDetailLab;

@property (nonatomic,strong) UIButton *chooseLeaveTimeBtn;

@property (nonatomic,strong) UIButton *chooseArriveTimeBtn;

@property (nonatomic,strong) UIButton *arriveAmBtn;

@property (nonatomic,strong) UIButton *arrivePmBtn;

@property (nonatomic,strong) UIButton *leaveAmBtn;

@property (nonatomic,strong) UIButton *leavePmBtn;

@end
