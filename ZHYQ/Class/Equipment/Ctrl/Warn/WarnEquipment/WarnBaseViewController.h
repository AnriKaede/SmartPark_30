//
//  WarnBaseViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"

@protocol ScrollStopDelegate <NSObject>

- (void)stopScroll:(CGFloat)endY;

@end

@interface WarnBaseViewController : RootViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UITableView *warnTableView;
@property (nonatomic,assign) CGFloat headerHeight;

@property (nonatomic,assign) id<ScrollStopDelegate> scrollStopDelegate;

- (instancetype)initWithHeaderHeight:(CGFloat)height;

@end
