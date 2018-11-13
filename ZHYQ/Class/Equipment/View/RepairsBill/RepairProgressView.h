//
//  RepairProgressView.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/17.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairProgressView : UIView

//@property (nonatomic,copy) NSArray *progressData;

- (void)showProgress:(NSString *)billId;
- (void)hidProgress;

@end
