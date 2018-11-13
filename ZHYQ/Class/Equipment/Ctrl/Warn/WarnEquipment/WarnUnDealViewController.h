//
//  WarnUnDealViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WarnBaseViewController.h"
#import "WranUndealModel.h"

@protocol ConfirmWramWindowDelegate <NSObject>

- (void)showConfirm:(WranUndealModel *)wranUndealModel;
- (void)hidConfirm;

@end

@interface WarnUnDealViewController : WarnBaseViewController

@property (nonatomic,assign) id<ConfirmWramWindowDelegate> confirmWramWindowDelegate;

@end
