//
//  SetFooterView.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactCtrlDelegate

-(void)DismissContactsCtrl;

@end

@interface SetFooterView : UIView

@property (nonatomic,strong) UIButton *logOutBtn;

@property (nonatomic,weak) id<ContactCtrlDelegate> delegate;

@end
